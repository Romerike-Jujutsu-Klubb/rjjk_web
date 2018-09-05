#!/bin/bash -el

DB_NAME=rjjk_web_development

echo "Disconnecting clients"
set +e
echo "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity
    WHERE datname = '$DB_NAME' AND state = 'idle';" | psql $DB_NAME
set -e

echo "Re-creating database"
dropdb --if-exists $DB_NAME
bin/rake db:create

echo "Transferring database"
time cat `ls tmp/prod* | tail -1` | gunzip | sed -e s/capistrano/uwe/ | psql $DB_NAME

export JRUBY_OPTS=--dev
RAILS_ENV=development bundle exec rake db:migrate
