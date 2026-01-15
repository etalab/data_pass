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
AGGREGATOR_FILE="${SCRIPT_DIR}/aggregator.rb"
REPORT_FILE="${SCRIPT_DIR}/report.rb"
MAIN_FILE="${SCRIPT_DIR}/main.rb"

# Generate output filename with current date
OUTPUT_FILE="${SCRIPT_DIR}/results/stats_$(date +%Y-%m-%d).md"

# Check if files exist
if [ ! -f "$AGGREGATOR_FILE" ]; then
  echo "Error: aggregator.rb not found at $AGGREGATOR_FILE"
  exit 1
fi

if [ ! -f "$REPORT_FILE" ]; then
  echo "Error: report.rb not found at $REPORT_FILE"
  exit 1
fi

if [ ! -f "$MAIN_FILE" ]; then
  echo "Error: main.rb not found at $MAIN_FILE"
  exit 1
fi

# Ensure results directory exists
mkdir -p "${SCRIPT_DIR}/results"

echo "Executing stats in local Rails console..." >&2
echo "========================================" >&2
echo "Loading aggregator.rb, report.rb, and executing main.rb..." >&2
echo "" >&2

# Execute the Ruby code in the local Rails console via Docker
# Use a temporary file to capture the full output, then extract just the report
TEMP_OUTPUT=$(mktemp)

cd "$PROJECT_ROOT"
docker compose run --rm --entrypoint="" web bin/rails runner - > "$TEMP_OUTPUT" 2>&1 << EOF
$(cat "$AGGREGATOR_FILE")

$(cat "$REPORT_FILE")

$(cat "$MAIN_FILE")
EOF

# Extract only the content between markers (excluding the markers themselves)
sed -n '/===BEGIN_OF_REPORT===/,/===END_OF_REPORT===/p' "$TEMP_OUTPUT" | sed '1d;$d' > "$OUTPUT_FILE"

# Clean up
rm -f "$TEMP_OUTPUT"

echo "" >&2
echo "========================================" >&2
echo "Execution complete!" >&2
echo "Output saved to: $OUTPUT_FILE" >&2
