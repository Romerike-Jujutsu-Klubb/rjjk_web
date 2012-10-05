#!/bin/bash -e

DB_NAME=rjjk_web_development
DUMP_FILE=rjjk_production_`date +'%Y-%m-%d'`.sql.gz

echo "Disconnecting clients"
echo "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity
    WHERE datname = '$DB_NAME' AND state = 'idle';" | psql -h localhost $DB_NAME

echo "Re-creating database"
dropdb -h localhost $DB_NAME # --if-exists
createdb -h localhost $DB_NAME

echo "Transferring database"
ssh root@kubosch.no "pg_dump -U capistrano rjjk_production | gzip" |
    gunzip | sed -e s/capistrano/uwe/ | psql -h localhost $DB_NAME
