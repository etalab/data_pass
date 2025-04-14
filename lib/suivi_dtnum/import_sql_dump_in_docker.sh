#!/bin/bash

# This script imports a SQL dump into the development database in Docker
# It first drops all existing tables and then imports the dump

# Drop all existing tables and recreate the schema
docker compose exec db psql -U postgres -d development -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Copy the SQL dump to the container and import it
docker compose cp "lib/suivi DTNUM/sources/dump-all-2025-04-15.sql" db:/tmp/dump.sql
docker compose exec db psql -U postgres -d development -f /tmp/dump.sql

# Note: You might see errors about role "skelz0r" not existing, but these can be safely ignored
# as they don't affect the data import. The tables will be owned by the postgres user instead.
