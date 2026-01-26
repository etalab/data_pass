#!/bin/bash

# Script to generate stats report from local database (with production data)
# Usage: ./app/services/stats/generate_report.sh
# Output: Creates a file in results/ with the current date
#
# Prerequisites: Run ./app/services/stats/download_prod_db.sh first to load production data

set -e  # Exit on error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

echo "Generating stats report..."
echo "========================================" >&2

cd "$PROJECT_ROOT"
docker compose run --rm --entrypoint="" web bin/rails runner "app/services/stats/main.rb"
