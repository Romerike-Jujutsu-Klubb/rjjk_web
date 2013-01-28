#!/bin/bash -e

DB_NAME=rjjk_web_beta
MARKER_PREFIX="/tmp/${DB_NAME}_backup_"
MARKER_FILE="${MARKER_PREFIX}`date +%Y-%m-%d`"

if [ -e $MARKER_FILE ] ; then
  exit 0
fi
rm -f ${MARKER_PREFIX}*

echo "Re-creating database"
dropdb -h localhost $DB_NAME
createdb -h localhost $DB_NAME

echo "Transferring database"
pg_dump -U capistrano rjjk_production | psql -U capistrano -h localhost $DB_NAME

touch $MARKER_FILE
