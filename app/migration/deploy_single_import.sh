RAILS_ENV=production

[ -f app/migration/dumps/data.db ] && LOCAL=true bundle exec rails runner "ImportDataInLocalDb.new.perform(delete_db_file: false)" || exit 1

scp app/migration/.ovh.yml watchdoge:.
ssh -A watchdoge -- sudo mv .ovh.yml /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
ssh -A watchdoge -- sudo chown root:root /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.ovh.yml
ssh -A watchdoge -- sudo chmod 644 /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/.ovh.yml

ssh -A watchdoge -- sudo rm -rf dumps/
ssh -A watchdoge -- mkdir dumps/

scp app/migration/dumps/data.db watchdoge:dumps/
scp app/migration/dumps/*.csv watchdoge:dumps/

ssh -A watchdoge -- sudo chown -R root:root dumps/
ssh -A watchdoge -- sudo chmod -R 644 dumps/
ssh -A watchdoge -- sudo rm -rf /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/
ssh -A watchdoge -- sudo cp dumps -r /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/
ssh -A watchdoge -- sudo chmod -R og+r /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps/
ssh -A watchdoge -- sudo chmod o+x /var/www/datapass_reborn_$RAILS_ENV/current/app/migration/dumps
