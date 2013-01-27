#!/bin/bash -e

DB_NAME=rjjk_web_beta
MARKER_PREFIX="/tmp/${DB_NAME}_backup_"
MARKER_FILE="${MARKER_PREFIX}`date +%Y-%m-%d`"

if [ -e $MARKER_FILE ] ; then
  exit 0
fi
rm -f ${MARKER_PREFIX}*

echo "Disconnecting clients"
# echo "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity
#     WHERE datname = '$DB_NAME' AND state = 'idle';" | psql -h localhost $DB_NAME
echo "SELECT procpid, (SELECT pg_terminate_backend(procpid)) as killed from pg_stat_activity
    WHERE datname = '$DB_NAME';" | psql -h localhost $DB_NAME

echo "Re-creating database"
dropdb -h localhost $DB_NAME # --if-exists
createdb -h localhost $DB_NAME

echo "Transferring database"
pg_dump -U capistrano rjjk_production | psql -U capistrano -h localhost $DB_NAME

touch $MARKER_FILE
