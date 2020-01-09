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
time pg_dump "$(heroku config:get --app=jujutsu-no HEROKU_POSTGRESQL_CRIMSON_URL)" | psql $DB_NAME

export JRUBY_OPTS=--dev
export RAILS_ENV=development
bundle exec rake db:migrate
bin/rails r "Image.all.each{|i| i.update!(cloudinary_identifier: nil) if i.cloudinary_identifier =~ %r{production/images}}"
RAILS_ENV="test" bundle exec rake db:reset
