#!/bin/bash

RAILS_ENV=sandbox
HOST=watchdoge5
SANDBOX_BRANCH=migration/scripts

# 1. Deploy latest version of code
if [ $RAILS_ENV = 'sandbox' ] ; then
  ssh -A $HOST -- sudo RAILS_APP_BRANCH=$SANDBOX_BRANCH -u ci_deploy /usr/local/bin/rails_deploy_datapass_reborn_$RAILS_ENV.sh
else
  ssh -A $HOST -- sudo RAILS_APP_BRANCH=develop -u ci_deploy /usr/local/bin/rails_deploy_datapass_reborn_$RAILS_ENV.sh
fi

# 2. Copy pgpassword
scp app/migration/.v1-pgpassword $HOST:.
ssh -A $HOST -- sudo mv .v1-pgpassword /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
ssh -A $HOST -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.v1-pgpassword
ssh -A $HOST -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.v1-pgpassword

# 3. Copy run.sh
scp app/migration/run.sh $HOST:.
ssh -A $HOST -- sudo mv run.sh /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
ssh -A $HOST -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/run.sh
ssh -A $HOST -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/run.sh

# 4. Copy ovh credentials
scp app/migration/.ovh.yml $HOST:.
ssh -A $HOST -- sudo mv .ovh.yml /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
ssh -A $HOST -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.ovh.yml
ssh -A $HOST -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.ovh.yml

# # 5. Copy hubee credentials
# scp app/migration/.hubee_config.yml $HOST:.
# ssh -A $HOST -- sudo mv .hubee_config.yml /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
# ssh -A $HOST -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.hubee_config.yml
# ssh -A $HOST -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.hubee_config.yml

if [ $RAILS_ENV = 'sandbox' ] ; then
  v2_pg_password_sandbox=`cat app/migration/.v2-pgpassword-sandbox`
  # pg_dump --clean -F c -b -v -h localhost -d development -f sandbox/latest.dump
  dump_to_load=sandbox/latest.dump # app/migration/dumps/datapass_production_v2.dump

  echo "[SANDBOX ONLY] Copy dump and execute it"
  scp $dump_to_load $HOST:datapass_production_v2.dump
  ssh -A $HOST -- sudo mv datapass_production_v2.dump /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps
  ssh -A $HOST -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/datapass_production_v2.dump
  ssh -A $HOST -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/datapass_production_v2.dump
  echo "localhost:5432:datapass_reborn_sandbox:datapass_reborn_sandbox:$v2_pg_password_sandbox" > pgpass
  scp pgpass $HOST:.pgpass
  ssh -A $HOST -- chmod 600 .pgpass
  rm pgpass

  ssh -A $HOST -- pg_restore --clean -d datapass_reborn_sandbox -U datapass_reborn_sandbox -h localhost -p 5432 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/datapass_production_v2.dump
  ssh -A $HOST -- rm -f ~/.pgpass

  echo "Deploy on sandbox done, please execute the following commands within /var/www/datapass_reborn_sandbox/current to finish the setup:"
  echo "  sudo -u datapass_reborn_sandbox bundle exec rails runner "CreateSandboxOauthApp.new.perform" -e sandbox"
  echo "  sudo -u datapass_reborn_sandbox bundle exec rails db:environment:set RAILS_ENV=sandbox"
fi

# Optional: cp local built data to speed-up import
# ssh -A $HOST -- sudo cp /var/www/datapass_reborn_$RAILS_ENV/data.db /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/
# ssh -A $HOST -- sudo cp /var/www/datapass_reborn_$RAILS_ENV/app/migration/dumps/*.sql /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/
