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

echo ">> Run hubee import script"
sudo --preserve-env=RAILS_ENV,LOCAL,SKIP_DOCUMENT_VALIDATION -u datapass_reborn_$RAILS_ENV bundle exec rails runner "HubEEImport.instance.build_csv_from_api"

echo ">> Create db sqlite"
sudo -u datapass_reborn_$RAILS_ENV --preserve-env=RAILS_ENV bundle exec rails runner "ImportDataInLocalDb.new.perform(delete_db_file: false)"

echo ">> Run main import script"
sudo --preserve-env=RAILS_ENV,LOCAL,SKIP_DOCUMENT_VALIDATION -u datapass_reborn_$RAILS_ENV bundle exec rails runner "MainImport.new.perform"

# Faire tourner le script app/migration/build_instructor_migration.rb sur DataPass v1
echo ">> Assign instructor/reporter roles"
sudo --preserve-env=RAILS_ENV,LOCAL -u datapass_reborn_$RAILS_ENV bundle exec rails runner "
ActiveRecord::Base.transaction do
  User.where(external_id: %w[22401 81204 118929 78744 250299]).find_each do |user|
    user.roles << 'hubee_cert_dc:instructor'

    if %w[ 22401 81204 118929 78744 250299].exclude?(user.external_id)
      user.instruction_submit_notifications_for_hubee_cert_dc = false
      user.instruction_messages_notifications_for_hubee_cert_dc = false
    end

    user.save!
  end
  User.where(external_id: %w[34228 34424 50762 34229  65959 22401 34283 26213  81204 118929 30206 78406 78744 116 68406 34178 122526 57483 78736 250299]).find_each do |user|
    user.roles << 'hubee_cert_dc:reporter'

    if %w[ 22401 81204 118929 78744 250299].exclude?(user.external_id)
      user.instruction_submit_notifications_for_hubee_cert_dc = false
      user.instruction_messages_notifications_for_hubee_cert_dc = false
    end

    user.save!
  end
  User.where(external_id: %w[85026 82789  195410 105596 37150 159065 83997 130064]).find_each do |user|
    user.roles << 'hubee_dila:instructor'

    if %w[42408 130064].exclude?(user.external_id)
      user.instruction_submit_notifications_for_hubee_dila = false
      user.instruction_messages_notifications_for_hubee_dila = false
    end

    user.save!
  end
  User.where(external_id: %w[34424 50762 34229  65959 85026  82789 26213   43079 93628 195410 93626 105596 37150 30206 78406 159065 116 68406 34178 40073 122526 83997 57483 130064 78736]).find_each do |user|
    user.roles << 'hubee_dila:reporter'

    if %w[42408 130064].exclude?(user.external_id)
      user.instruction_submit_notifications_for_hubee_dila = false
      user.instruction_messages_notifications_for_hubee_dila = false
    end

    user.save!
  end
end
"

echo ">> Maintenance mode OFF"
sudo rm -f /var/www/html/maintenance_datapass_$RAILS_ENV.html

echo ">> Cleaning up"
rm -f ~/.pgpass
rm -rf ~/dumps

echo ">> Done"
