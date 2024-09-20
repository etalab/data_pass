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

echo ">> Create db sqlite"
sudo -u datapass_reborn_$RAILS_ENV --preserve-env=RAILS_ENV bundle exec rails runner "ImportDataInLocalDb.new.perform(delete_db_file: false)"

echo ">> Run main import script"
sudo --preserve-env=RAILS_ENV,LOCAL,SKIP_DOCUMENT_VALIDATION -u datapass_reborn_$RAILS_ENV bundle exec rails runner "MainImport.new.perform"

# Utiliser la ligne ci-dessous pour récuperer les ids. instructor et reporter sont les 2 blocs, subscriber = email
# User.with_at_least_one_role.to_a.select { |u| u.roles.any? { |r| r == 'api_particulier:subscriber' } }.map { |u| u.uid }.join(' ')
echo ">> Assign instructor roles"
sudo --preserve-env=RAILS_ENV,LOCAL -u datapass_reborn_$RAILS_ENV bundle exec rails runner "
ActiveRecord::Base.transaction do
  User.where(external_id: %w[16574 26213 183892 3164 86663 78010 122526 243]).find_each do |user|
    user.roles << 'api_particulier:instructor'

    if %w[78010 122526 243].exclude?(user.external_id)
      user.instruction_submit_notifications_for_api_particulier = false
      user.instruction_messages_notifications_for_api_particulier  = false
    end

    user.save!
  end

  User.where(external_id: %w[45965 29397 16574 33577 78736 57483 26213  34758 28852 146936 163815 183892 68398 12912 15241 69166 3164 86663 78406 116 35009 78010 34178 46027 122526 243 34461]).find_each do |user|
    user.roles << 'api_particulier:reporter'

    if %w[78010 122526 243].exclude?(user.external_id)
      user.instruction_submit_notifications_for_api_particulier = false
      user.instruction_messages_notifications_for_api_particulier  = false
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
