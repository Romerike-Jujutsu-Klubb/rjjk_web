#!/bin/bash -e

DB_NAME=rjjk_web_beta
MARKER_PREFIX="/tmp/${DB_NAME}_backup_"
MARKER_FILE="${MARKER_PREFIX}`date +%Y-%m-%d`"

export JRUBY_OPTS="--dev -J-Xmx2G"
export RAILS_ENV=beta

if [ -e $MARKER_FILE ] ; then
  exit 0
fi
rm -f ${MARKER_PREFIX}*

cd /u/apps/rjjk_web_beta/current

echo "Re-creating database"
ruby -v
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:drop db:create

echo "Transferring database"
pg_dump -U capistrano -h localhost rjjk_production | psql -U capistrano -h localhost $DB_NAME

bundle exec rake db:migrate

touch $MARKER_FILE
