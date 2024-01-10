#!/bin/bash

user=skelz0r
host=watchdoge
pg_password=`cat migration/.pgpassword`

echo ">> Init pg access"
ssh $user@$host "echo \"localhost:5432:datapass_production:datapass_production:$pg_password\" > ~/.pgpass && chmod 600 ~/.pgpass && mkdir dumps 2> /dev/null"

tables=(enrollments users team_members events organizations)

for table in "${tables[@]}"
do
  echo ">> Dumping $table"
  ssh $user@$host "psql -h localhost -U datapass_production -d datapass_production -c \"COPY (SELECT * FROM $table) TO STDOUT WITH CSV HEADER\" > dumps/$table.csv"
done

echo ">> Downloading dumps"
scp $user@$host:dumps/* migration/dumps/

echo ">> Cleaning up"
ssh $user@$host "rm ~/.pgpass && rm -rf dumps"

echo ">> Done"
