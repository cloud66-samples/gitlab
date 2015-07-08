FROM ubuntu:14.04
MAINTAINER Philip Kallberg <philip@cloud66.com>

# Install required packages
RUN apt-get install -qy --no-install-recommends \
      openssh-server \
      ca-certificates \
      curl \
    && curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash \
    && apt-get install -qy --no-install-recommends \
      gitlab-ce=7.10.4~omnibus.1-1

RUN mkdir -p /opt/gitlab/sv/sshd/supervise \
    && mkfifo /opt/gitlab/sv/sshd/supervise/ok \
    && printf "#!/bin/sh\nexec 2>&1\numask 077\nexec /usr/sbin/sshd -D" > /opt/gitlab/sv/sshd/run \
    && chmod a+x /opt/gitlab/sv/sshd/run \
    && ln -s /opt/gitlab/sv/sshd /opt/gitlab/service \
    && mkdir -p /var/run/sshd

COPY entrypoint.sh /etc/gitlab/entrypoint.sh
RUN chmod 755 /etc/gitlab/entrypoint.sh

# Expose web & ssh
EXPOSE 80 22

ENTRYPOINT ["/etc/gitlab/entrypoint.sh"]

#CMD sleep 3 && gitlab-ctl reconfigure & /opt/gitlab/embedded/bin/runsvdir-start
