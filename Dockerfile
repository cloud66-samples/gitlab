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

RUN cd /etc/gitlab \
    && sed -i "s/^.*db_database.*$/gitlab_rails[\'db_database\'] = ENV[\"POSTGRESQL_DATABASE\"]/" gitlab.rb \
    && sed -i "s/^.*db_username.*$/gitlab_rails[\'db_username\'] = ENV[\"POSTGRESQL_USERNAME\"]/" gitlab.rb \
    && sed -i "s/^.*db_password.*$/gitlab_rails[\'db_password\'] = ENV[\"POSTGRESQL_PASSWORD\"]/" gitlab.rb \
    && sed -i "s/^.*db_host.*$/gitlab_rails[\'db_host\'] = ENV[\"POSTGRESQL_ADDRESS\"]/" gitlab.rb \
    && sed -i "s/^.*db_port.*$/gitlab_rails[\'db_port\'] = "5432"/" gitlab.rb \ 
    && sed -i "s/^.*redis_host.*$/gitlab_ci[\'redis_host\'] = ENV[\"REDIS_ADDRESS\"]/" gitlab.rb \
    && sed -i "s/^.*redis_port.*$/gitlab_ci[\'redis_port\'] = "6379"/" gitlab.rb

# Expose web & ssh
EXPOSE 80 22

RUN mv /etc/gitlab/gitlab.rb /tmp/gitlab.rb

CMD sleep 3 && mv /tmp/gitlab.rb /etc/gitlab/gitlab.rb && gitlab-ctl reconfigure & /opt/gitlab/embedded/bin/runsvdir-start
