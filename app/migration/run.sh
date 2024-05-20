#!/bin/bash

user=skelz0r
host=watchdoge
pg_password=`cat app/migration/.pgpassword`

cd /var/www/datapass_reborn_$RAILS_ENV/current

## TODO TO CHANGE
RAILS_ENV=staging
LOCAL=true
## END TODO

export RAILS_ENV LOCAL

## Process ici: https://pad.incubateur.net/xMY2MVZ1STexUrU8yfYMng

echo ">> Maintenance mode ON"
sudo cp app/migration/maintenance.html /var/www/html/maintenance_datapass_$RAILS_ENV.html
sudo chmod 644 /var/www/html/maintenance_datapass_$RAILS_ENV.html

echo ">> Export des dumps"
echo "localhost:5432:datapass_production:datapass_production:$pg_password" > ~/.pgpass && chmod 600 ~/.pgpass
tables=(enrollments users team_members events organizations documents snapshots snapshot_items)

for table in "${tables[@]}"
do
  echo ">> Dumping $table"
  psql -h localhost -U datapass_production -d datapass_production -c "COPY (SELECT * FROM $table) TO STDOUT WITH CSV HEADER" > app/migration/dumps/$table.csv 2> /dev/null
done

sudo chown datapass_reborn_$RAILS_ENV:datapass_reborn_$RAILS_ENV app/migration/dumps
sudo chown datapass_reborn_$RAILS_ENV:datapass_reborn_$RAILS_ENV app/migration/dumps/*

echo ">> Create db sqlite"
sudo -u datapass_reborn_$RAILS_ENV --preserve-env=RAILS_ENV bundle exec rails runner "ImportDataInLocalDb.new.perform(delete_db_file: false)"

echo ">> Drop local database"
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 sudo --preserve-env=RAILS_ENV,PATH,DISABLE_DATABASE_ENVIRONMENT_CHECK -u datapass_reborn_$RAILS_ENV bundle exec rails db:schema:load

echo ">> Run main import script"
sudo --preserve-env=RAILS_ENV,LOCAL -u datapass_reborn_$RAILS_ENV bundle exec rails runner "MainImport.new.perform"

echo ">> Change authorization request id sequence"
sudo --preserve-env=RAILS_ENV,LOCAL -u datapass_reborn_$RAILS_ENV bundle exec rails runner "ActiveRecord::Base.connection.execute(\"select setval('authorization_requests_id_seq', 87045, true);\")"

echo ">> Maintenance mode OFF"
sudo rm -f /var/www/html/maintenance_datapass.html

echo ">> Cleaning up"
rm -f ~/.pgpass
rm -rf ~/dumps

echo ">> Done"
