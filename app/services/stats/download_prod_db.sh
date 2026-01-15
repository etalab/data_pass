#!/bin/bash

# Script to download production database and load it locally
# Usage: ./app/services/stats/download_prod_db.sh [--force-download]
# 
# This script will:
# 1. Download the production database via SSH (if not already cached or --force-download is used)
# 2. Drop and recreate the local development database
# 3. Load the production dump into local development database
#
# Options:
#   --force-download    Force re-download even if cached dump exists

set -e  # Exit on error

app_name=datapass_reborn
env="production"


# Get local database name from environment or use default
LOCAL_DB="${DATABASE_DEVELOPMENT_NAME:-data_pass_development}"

# Store dump file in /tmp with a recognizable name
DUMP_FILE="/tmp/datapass_prod_db_dump_$(date +%Y-%m-%d).sql"
LATEST_DUMP_LINK="/tmp/datapass_prod_db_dump_latest.sql"

echo "==========================================" >&2
echo "Production database download & load" >&2
echo "==========================================" >&2
echo "" >&2

# Check if we should force download
FORCE_DOWNLOAD=false
if [ "$1" = "--force-download" ]; then
  FORCE_DOWNLOAD=true
  echo "Forced download requested" >&2
fi

# Check if dump file already exists
if [ -f "$DUMP_FILE" ] && [ "$FORCE_DOWNLOAD" = false ]; then
  echo "Using cached dump file: $DUMP_FILE" >&2
  echo "(Use --force-download to re-download from production)" >&2
  echo "" >&2
elif [ -f "$LATEST_DUMP_LINK" ] && [ "$FORCE_DOWNLOAD" = false ]; then
  echo "Using latest cached dump file: $LATEST_DUMP_LINK" >&2
  echo "(Use --force-download to re-download from production)" >&2
  DUMP_FILE="$LATEST_DUMP_LINK"
  echo "" >&2
else
  echo "Step 1: Dumping production database..." >&2
  # Dump the production database via SSH
  # The pg_dump command runs on the remote server and outputs to stdout, which we capture locally
  # Using peer authentication (no password needed when running as the correct user)
  ssh watchdoge "sudo -u ${app_name}_${env} pg_dump ${app_name}_${env} --no-owner --no-privileges" > "$DUMP_FILE"

  if [ $? -ne 0 ]; then
    echo "Error: Failed to dump production database" >&2
    rm -f "$DUMP_FILE"
    exit 1
  fi
  
  # Create/update a symlink to the latest dump
  ln -sf "$(basename "$DUMP_FILE")" "$LATEST_DUMP_LINK"
  
  echo "Dump saved to: $DUMP_FILE" >&2
  echo "" >&2
fi

echo "Step 2: Ensuring database container is ready..." >&2
# Make sure the database container is running
docker compose up -d db

echo "Step 3: Terminating connections and dropping database..." >&2
# Terminate all connections to the database before dropping
docker compose exec -T db psql -U postgres -p 5433 -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$LOCAL_DB' AND pid <> pg_backend_pid();" 2>/dev/null || true

# Wait a moment for connections to close
sleep 2

# Drop the database
docker compose exec -T db psql -U postgres -p 5433 -c "DROP DATABASE IF EXISTS $LOCAL_DB;" 2>/dev/null || true

echo "Step 4: Creating Docker development database..." >&2
# Create a fresh database in the Docker container
docker compose exec -T db psql -U postgres -p 5433 -c "CREATE DATABASE $LOCAL_DB;"

echo "Step 5: Loading production dump into Docker database..." >&2
# Load the dump into the Docker database
# We need to pass the dump file through stdin to psql in the container
cat "$DUMP_FILE" | docker compose exec -T db psql -U postgres -p 5433 -d "$LOCAL_DB"

if [ $? -ne 0 ]; then
  echo "Error: Failed to load dump into local database" >&2
  rm -f "$DUMP_FILE"
  exit 1
fi

# Clean up
rm -f "$DUMP_FILE"

echo "" >&2
echo "==========================================" >&2
echo "Success! Production database loaded locally" >&2
echo "Database: $LOCAL_DB" >&2
echo "==========================================" >&2
