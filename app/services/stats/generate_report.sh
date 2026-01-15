#!/bin/bash

# Script to generate stats report from production console
# Usage: ./app/services/stats/generate_report.sh
# Output: Creates a file in results/ with the current date

app_name=datapass_reborn
env="production"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

echo "Executing stats in production console..." >&2
echo "========================================" >&2
echo "Loading aggregator.rb, report.rb, and executing main.rb..." >&2
echo "" >&2

# Execute the Ruby code in the remote console and extract only the report content
# We send the actual file contents since they don't exist in prod yet
# Use a temporary file to capture the full output, then extract just the report
TEMP_OUTPUT=$(mktemp)

ssh watchdoge /usr/local/bin/console_${app_name}_${env}.sh > "$TEMP_OUTPUT" 2>&1 << EOF
eval <<'RUBY_CODE'
$(cat "$AGGREGATOR_FILE")

$(cat "$REPORT_FILE")

$(cat "$MAIN_FILE")
RUBY_CODE
EOF

# Extract only the content between markers (excluding the markers themselves)
# We need to skip the echoed code and find the actual execution output
# Look for the pattern after "RUBY_CODE" line
sed -n '/^RUBY_CODE$/,/===END_OF_REPORT===/p' "$TEMP_OUTPUT" | sed -n '/===BEGIN_OF_REPORT===/,/===END_OF_REPORT===/p' | sed '1d;$d' > "$OUTPUT_FILE"

# Clean up
rm -f "$TEMP_OUTPUT"

echo "" >&2
echo "========================================" >&2
echo "Execution complete!" >&2
echo "Output saved to: $OUTPUT_FILE" >&2
