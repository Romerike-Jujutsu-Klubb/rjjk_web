#!/bin/bash -el

DB_NAME=rjjk_web_development

echo "Disconnecting clients"
set +e
echo "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity
    WHERE datname = '$DB_NAME' AND state = 'idle';" | psql $DB_NAME
set -e

echo "Re-creating database"
dropdb --if-exists $DB_NAME
createdb -T template0 -l en_US.UTF-8 $DB_NAME

echo "Transferring database"
time ssh root@kubosch.no "pg_dump -U capistrano rjjk_production | gzip" |
    gunzip | sed -e s/capistrano/uwe/ | psql $DB_NAME

rvm use jruby
export JRUBY_OPTS=--2.0
RAILS_ENV=development jruby -S bundle exec rake db:migrate
