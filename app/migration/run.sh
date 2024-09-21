#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <rails_env>"
  exit 1
fi

user=skelz0r
host=watchdoge
v1_pg_password=`cat app/migration/.v1-pgpassword`
RAILS_ENV=$1

## VARIABLES A POTENTIELLEMENT CHANGER
SKIP_DOCUMENT_VALIDATION=true
LOCAL=false
##

cd /var/www/datapass_reborn_$RAILS_ENV/current

export RAILS_ENV LOCAL SKIP_DOCUMENT_VALIDATION

## Process ici: https://pad.incubateur.net/xMY2MVZ1STexUrU8yfYMng

echo ">> Maintenance mode ON"
sudo cp app/migration/maintenance.html /var/www/html/maintenance_datapass_$RAILS_ENV.html
sudo service nginx reload
sudo chmod 644 /var/www/html/maintenance_datapass_$RAILS_ENV.html

echo ">> Export des dumps de la v1"
echo "localhost:5432:datapass_production:datapass_production:$v1_pg_password" > ~/.pgpass && chmod 600 ~/.pgpass
tables=(enrollments users team_members events organizations documents snapshots snapshot_items)

for table in "${tables[@]}"
do
  echo ">> Dumping $table"
  psql -h localhost -U datapass_production -d datapass_production -c "COPY (SELECT * FROM $table) TO STDOUT WITH CSV HEADER" > app/migration/dumps/$table.csv 2> /dev/null
done

sudo chown datapass_reborn_$RAILS_ENV:datapass_reborn_$RAILS_ENV app/migration/dumps
sudo chown datapass_reborn_$RAILS_ENV:datapass_reborn_$RAILS_ENV app/migration/dumps/*

# echo ">> Run hubee import script"
# sudo --preserve-env=RAILS_ENV,LOCAL,SKIP_DOCUMENT_VALIDATION -u datapass_reborn_$RAILS_ENV bundle exec rails runner "HubEEImport.instance.build_csv_from_api"

echo ">> Create db sqlite"
sudo -u datapass_reborn_$RAILS_ENV --preserve-env=RAILS_ENV bundle exec rails runner "ImportDataInLocalDb.new.perform(delete_db_file: false)"

echo ">> Run main import script"
sudo --preserve-env=RAILS_ENV,LOCAL,SKIP_DOCUMENT_VALIDATION -u datapass_reborn_$RAILS_ENV bundle exec rails runner "MainImport.new.perform"

# Faire tourner le script app/migration/build_instructor_migration.rb sur DataPass v1
echo ">> Assign instructor/reporter roles"
sudo --preserve-env=RAILS_ENV,LOCAL -u datapass_reborn_$RAILS_ENV bundle exec rails runner "
ActiveRecord::Base.transaction do
  raise 'FEEDME'
end
"
echo ">> Cleaning up"
rm -f ~/.pgpass
rm -rf ~/dumps

echo ">> Done"

echo ">>> Please run the following command to disable maintenance after post-migration operations described in https://pad.incubateur.net/xMY2MVZ1STexUrU8yfYMng?both"
echo "sudo rm -f /var/www/html/maintenance_datapass_$RAILS_ENV.html"
