#!/bin/bash -el

echo "Transferring database"
time ssh root@kubosch.no "pg_dump -U capistrano rjjk_production | gzip" > tmp/production_backup_`date +'%Y-%m-%d_%H-%M'`.psql.gz
