#!/bin/bash -e

DUMP_FILE=rjjk_production_`date +'%Y-%m-%d'`.sql.gz

echo "Dumping database"
# ssh root@kubosch.no "pg_dump -U capistrano rjjk_production | gzip" > $DUMP_FILE

echo "Loading database"
dropdb -h localhost rjjk_web_development
createdb -h localhost rjjk_web_development
gunzip -cf $DUMP_FILE | sed -e s/capistrano/uwe/ | psql -h localhost rjjk_web_development
