#!/bin/bash

dump_file="dump-all-2025-04-25.sql"

scp watchdoge:$dump_file ./lib/suivi_dtnum/sources/

# This script imports a SQL dump into the development database in Docker
# It first drops all existing tables and then imports the dump

# Drop all existing tables and recreate the schema
docker compose exec db psql -U postgres -d development -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Copy the SQL dump to the container and import it
docker compose cp "lib/suivi_dtnum/sources/$dump_file" db:/tmp/dump.sql
docker compose exec db psql -U postgres -d development -f /tmp/dump.sql

# Note: You might see errors about role "skelz0r" not existing, but these can be safely ignored
# as they don't affect the data import. The tables will be owned by the postgres user instead.

# Generate the matched ids file
docker compose exec web bundle exec rails runner lib/suivi_dtnum/v1_v2_ids_matcher/match_ids.rb

# Execute create_dgfip_developer_user.rb through Rails console in the web container
docker compose exec web bundle exec rails runner lib/suivi_dtnum/import/create_dgfip_developer_user.rb