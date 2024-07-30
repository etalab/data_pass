#!/bin/bash

user=skelz0r
host=watchdoge
v1_pg_password=`cat app/migration/.v1-pgpassword`

## TODO TO CHANGE
RAILS_ENV=production
SKIP_DOCUMENT_VALIDATION=true
LOCAL=false
## END TODO

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

echo ">> Drop local database"
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 sudo --preserve-env=RAILS_ENV,PATH,DISABLE_DATABASE_ENVIRONMENT_CHECK -u datapass_reborn_$RAILS_ENV bundle exec rails db:schema:load

echo ">> Run main import script"
sudo --preserve-env=RAILS_ENV,LOCAL,SKIP_DOCUMENT_VALIDATION -u datapass_reborn_$RAILS_ENV bundle exec rails runner "MainImport.new.perform"

# Utiliser la ligne ci-dessous pour récuperer les ids. instructor et reporter sont les 2 blocs, subscriber = email
# User.with_at_least_one_role.to_a.select { |u| u.roles.any? { |r| r == 'api_particulier:subscriber' } }.map { |u| u.id }.join(' ')
echo ">> Assign instructor roles"
sudo --preserve-env=RAILS_ENV,LOCAL -u datapass_reborn_$RAILS_ENV bundle exec rails runner "
ActiveRecord::Base.transaction do
  User.where(external_id: %w[12477 18036 74756 1723 70021 161 66116 71841]).find_each do |user|
    user.roles << 'api_particulier:instructor'

    if %w[161 66116 71841].exclude?(user.external_id)
      user.instruction_submit_notifications_for_api_particulier = false
      user.instruction_messages_notifications_for_api_particulier  = false
    end

    user.save!
  end

  User.where(external_id: %w[25602 19622 12477 21419 66668 47004 18036 72513 21960 19778 72326 74460 74756 58908 9745 21792 11251 25601 1723 70021 66439 161 63 22151 66116 21645 15601 71841]).find_each do |user|
    user.roles << 'api_particulier:reporter'

    if %w[161 66116 71841].exclude?(user.external_id)
      user.instruction_submit_notifications_for_api_particulier = false
      user.instruction_messages_notifications_for_api_particulier  = false
    end

    user.save!
  end
end
"

# echo ">> Maintenance mode OFF"
# sudo rm -f /var/www/html/maintenance_datapass.html

echo ">> Cleaning up"
rm -f ~/.pgpass
rm -rf ~/dumps

echo ">> Done"
