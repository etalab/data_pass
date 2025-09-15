#!/bin/bash

# Script to execute the match_ids_from_csv.rb script on the remote datapass production server
# This script should be executed on the remote server after uploading the necessary files

readonly RAILS_APP_FULLNAME=datapass_reborn_production
readonly RAILS_APP_DIR="/var/www/${RAILS_APP_FULLNAME}"
readonly RAILS_APP_USER=datapass_reborn_production
readonly RAILS_APP_ENV=production
readonly SCRIPT_DIR="/tmp"
readonly CSV_FILE="$SCRIPT_DIR/datapass_v1_ids.csv"
readonly RUBY_SCRIPT="$SCRIPT_DIR/match_ids_from_csv.rb"

echo "🚀 === DataPass V1/V2 IDs Matcher Remote Execution ==="
echo "📅 Started at: $(date)"
echo ""

# Check if required files exist
if [ ! -f "$CSV_FILE" ]; then
    echo "❌ Error: CSV file not found at $CSV_FILE"
    echo "Please ensure the CSV file has been uploaded to the remote server."
    exit 1
fi

if [ ! -f "$RUBY_SCRIPT" ]; then
    echo "❌ Error: Ruby script not found at $RUBY_SCRIPT"
    echo "Please ensure the Ruby script has been uploaded to the remote server."
    exit 1
fi

echo "✅ Found CSV file: $CSV_FILE"
echo "✅ Found Ruby script: $RUBY_SCRIPT"
echo ""

# Display CSV file info
echo "📊 CSV file information:"
echo "   Size: $(du -h "$CSV_FILE" | cut -f1)"
echo "   Lines: $(wc -l < "$CSV_FILE")"
echo ""

# Change to Rails app directory
echo "📁 Changing to Rails application directory: $RAILS_APP_DIR/current"
cd "$RAILS_APP_DIR/current" || {
    echo "❌ Error: Cannot change to Rails directory"
    exit 1
}

echo "🔄 Executing Ruby script via Rails runner..."
echo "Command: sudo -u $RAILS_APP_USER RAILS_ENV=$RAILS_APP_ENV bundle exec rails runner $RUBY_SCRIPT $CSV_FILE"
echo ""

# Execute the Ruby script through Rails using bundle exec (which worked in the first run)
sudo -u "$RAILS_APP_USER" RAILS_ENV="$RAILS_APP_ENV" bundle exec rails runner "$RUBY_SCRIPT" "$CSV_FILE"

exit_code=$?

echo ""
echo "📅 Finished at: $(date)"

if [ $exit_code -eq 0 ]; then
    echo "✅ Script execution completed successfully!"
    echo ""
    echo "📄 Generated files in /tmp/:"
    ls -la /tmp/matched_ids_result.csv /tmp/unmatched_v1_ids.csv /tmp/extra_demandes.csv /tmp/extra_authorizations.csv /tmp/ambiguous_demandes_left.csv 2>/dev/null | grep -v "No such file" || echo "Some result files may not have been generated"
else
    echo "❌ Script execution failed with exit code: $exit_code"
fi

exit $exit_code 