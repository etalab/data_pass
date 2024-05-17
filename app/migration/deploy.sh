#!/bin/bash

RAILS_ENV=staging

ssh -A watchdoge -- RAILS_APP_BRANCH=migration/api-entreprise /usr/local/bin/rails_deploy_datapass_reborn_$RAILS_ENV.sh
scp app/migration/.pgpassword watchdoge:.
ssh -A watchdoge -- sudo mv .pgpassword /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
scp app/migration/.ovh.yml watchdoge:.
ssh -A watchdoge -- sudo mv .ovh.yml /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
