#!/bin/bash

bundle exec rails db:drop db:create || exit 1
bundle exec rails db:environment:set RAILS_ENV=development
pg_restore -h localhost -d development app/migration/dumps/datapass_production_v2.dump 2> /dev/null
LOCAL=true bundle exec rails runner "ImportDataInLocalDb.new.perform(delete_db_file: false)"

if [ $# -eq 1 ]; then
  echo "Run for $1 only"
  DUMP=true LOCAL=true bundle exec rails runner "MainImport.new(authorization_request_ids: [$1]).perform"
else
  echo "Run for all"
  DUMP=true LOCAL=true bundle exec rails runner "MainImport.new.perform"
fi
