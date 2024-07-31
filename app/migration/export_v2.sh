#!/bin/bash

user=skelz0r
host=watchdoge
RAILS_ENV=production
pg_password=`cat app/migration/.v2-pgpassword-$RAILS_ENV`

echo ">> Init pg access"
ssh $user@$host "echo \"localhost:5432:datapass_reborn_$RAILS_ENV:datapass_reborn_$RAILS_ENV:$pg_password\" > ~/.pgpass && chmod 600 ~/.pgpass && mkdir dumps 2> /dev/null"

echo ">> Dump db v2"
ssh $user@$host "pg_dump  -F c -b -v -h localhost -U datapass_reborn_$RAILS_ENV -f dumps/datapass_${RAILS_ENV}_v2.dump datapass_reborn_$RAILS_ENV 2> /dev/null"

echo ">> Downloading dump"
scp $user@$host:dumps/datapass_${RAILS_ENV}_v2.dump app/migration/dumps/

echo ">> Cleaning up"
ssh $user@$host "rm ~/.pgpass && rm -rf dumps"

echo ">> Done"
