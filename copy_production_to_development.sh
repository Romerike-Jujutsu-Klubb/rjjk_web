#!/bin/bash -e

DB_NAME=rjjk_web_development
DUMP_FILE=rjjk_production_`date +'%Y-%m-%d'`.sql.gz

echo "Disconnecting clients"
echo "SELECT procpid, (SELECT pg_terminate_backend(procpid)) as killed from pg_stat_activity
    WHERE datname = '$DB_NAME' AND current_query LIKE '<IDLE>';" | psql -h localhost $DB_NAME

echo "Re-creating database"
dropdb -h localhost $DB_NAME
createdb -h localhost $DB_NAME

echo "Transferring database"
ssh root@kubosch.no "pg_dump -U capistrano rjjk_production | gzip" |
    gunzip | sed -e s/capistrano/uwe/ | psql -h localhost $DB_NAME
