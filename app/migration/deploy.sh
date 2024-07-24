#!/bin/bash

RAILS_ENV=production

# 1. Deploy latest version of code
ssh -A watchdoge -- RAILS_APP_BRANCH=develop /usr/local/bin/rails_deploy_datapass_reborn_$RAILS_ENV.sh

# 2. Copy pgpassword
scp app/migration/.pgpassword watchdoge:.
ssh -A watchdoge -- sudo mv .pgpassword /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
ssh -A watchdoge -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.pgpassword
ssh -A watchdoge -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.pgpassword

# 4. Copy ovh credentials
scp app/migration/.ovh.yml watchdoge:.
ssh -A watchdoge -- sudo mv .ovh.yml /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
ssh -A watchdoge -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.ovh.yml
ssh -A watchdoge -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.ovh.yml

# Optional: cp local built data to speed-up import
# ssh -A watchdoge -- sudo cp /var/www/datapass_reborn_$RAILS_ENV/data.db /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/
# ssh -A watchdoge -- sudo cp /var/www/datapass_reborn_$RAILS_ENV/app/migration/dumps/*.sql /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/
