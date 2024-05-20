#!/bin/bash

RAILS_ENV=production

ssh -A watchdoge -- RAILS_APP_BRANCH=develop /usr/local/bin/rails_deploy_datapass_reborn_$RAILS_ENV.sh
scp app/migration/.pgpassword watchdoge:.
ssh -A watchdoge -- sudo mv .pgpassword /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
ssh -A watchdoge -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.pgpassword
ssh -A watchdoge -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.pgpassword

scp app/migration/.ovh.yml watchdoge:.
ssh -A watchdoge -- sudo mv .ovh.yml /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
ssh -A watchdoge -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.ovh.yml
ssh -A watchdoge -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.ovh.yml


ssh -A watchdoge -- sudo cp /var/www/datapass_reborn_$RAILS_ENV/data.db /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/
ssh -A watchdoge -- sudo cp /var/www/datapass_reborn_$RAILS_ENV/app/migration/dumps/*.sql /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/
