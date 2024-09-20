#!/bin/bash

RAILS_ENV=sandbox

# 1. Deploy latest version of code
ssh -A watchdoge -- sudo RAILS_APP_BRANCH=develop -u ci_deploy /usr/local/bin/rails_deploy_datapass_reborn_$RAILS_ENV.sh

# # 2. Copy pgpassword
scp app/migration/.v1-pgpassword watchdoge:.
ssh -A watchdoge -- sudo mv .v1-pgpassword /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
ssh -A watchdoge -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.v1-pgpassword
ssh -A watchdoge -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.v1-pgpassword

# 3. Copy run.sh
scp app/migration/run.sh watchdoge:.
ssh -A watchdoge -- sudo mv run.sh /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
ssh -A watchdoge -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/run.sh
ssh -A watchdoge -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/run.sh

# 4. Copy ovh credentials
scp app/migration/.ovh.yml watchdoge:.
ssh -A watchdoge -- sudo mv .ovh.yml /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
ssh -A watchdoge -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.ovh.yml
ssh -A watchdoge -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.ovh.yml

# 4. Copy hubee credentials
scp app/migration/.hubee_config.yml watchdoge:.
ssh -A watchdoge -- sudo mv .hubee_config.yml /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
ssh -A watchdoge -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.hubee_config.yml
ssh -A watchdoge -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.hubee_config.yml


if [ $RAILS_ENV = 'sandbox' ] ; then
  v2_pg_password_sandbox=`cat app/migration/.v2-pgpassword-sandbox`

  echo "[SANDBOX ONLY] Copy dump and execute it"
  scp app/migration/dumps/datapass_production_v2.dump watchdoge:.
  ssh -A watchdoge -- sudo mv datapass_production_v2.dump /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps
  ssh -A watchdoge -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/datapass_production_v2.dump
  ssh -A watchdoge -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/datapass_production_v2.dump
  echo "localhost:5432:datapass_reborn_sandbox:datapass_reborn_sandbox:$v2_pg_password_sandbox" > pgpass
  scp pgpass watchdoge:.pgpass
  ssh -A watchdoge -- chmod 600 .pgpass
  rm pgpass

  ssh -A watchdoge -- pg_restore -d datapass_reborn_sandbox -U datapass_reborn_sandbox -h localhost -p 5432 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/datapass_production_v2.dump
  ssh -A watchdoge -- rm -f ~/.pgpass
fi

# Optional: cp local built data to speed-up import
# ssh -A watchdoge -- sudo cp /var/www/datapass_reborn_$RAILS_ENV/data.db /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/
# ssh -A watchdoge -- sudo cp /var/www/datapass_reborn_$RAILS_ENV/app/migration/dumps/*.sql /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/
