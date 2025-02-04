#!/bin/bash

rm -f app/migration/dumps/*.sql
rm -f app/migration/dumps/*.csv
rm -f app/migration/dumps/*.json
rm -f app/migration/dumps/data.db
./app/migration/export_v1.sh
./app/migration/export_v2.sh
# ./app/migration/export_hubee.sh
