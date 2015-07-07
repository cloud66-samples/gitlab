#!/bin/bash
cd /etc/gitlab

# Setting environment variables for database connection
sed -i 's/^.*db_database.*$/gitlab_rails['db_database'] = ENV[\"POSTGRESQL_DATABASE\"]/' gitlab.rb
sed -i 's/^.*db_username.*$/gitlab_rails['db_username'] = ENV[\"POSTGRESQL_USERNAME\"]/' gitlab.rb
sed -i 's/^.*db_password.*$/gitlab_rails['db_password'] = ENV[\"POSTGRESQL_PASSWORD\"]/' gitlab.rb
sed -i 's/^.*db_host.*$/gitlab_rails['db_host'] = ENV[\"POSTGRESQL_ADDRESS\"]/' gitlab.rb
sed -i 's/^.*db_port.*$/gitlab_rails['db_port'] = "5432"/' gitlab.rb

# Setting environment variables for Redis connection
sed -i 's/^.*redis_host.*$/gitlab_ci['redis_host'] = ENV[\"REDIS_ADDRESS\"]/' gitlab.rb
sed -i 's/^.*redis_port.*$/gitlab_ci['redis_port'] = "6379"/' gitlab.rb

gitlab-ctl reconfigure & /opt/gitlab/embedded/bin/runsvdir-start
