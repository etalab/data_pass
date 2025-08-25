#!/bin/bash

# Main script to execute DataPass V1/V2 IDs matching on remote server
# This script uploads the necessary files, executes the matching, and downloads the results

set -e  # Exit on any error

# Configuration
readonly REMOTE_HOST="watchdoge"
readonly REMOTE_TMP="/tmp"
readonly LOCAL_SCRIPT_DIR="lib/suivi_dtnum/v1_v2_ids_matcher"
readonly TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
readonly RESULTS_DIR="$LOCAL_SCRIPT_DIR/results_$TIMESTAMP"

# File paths
readonly LOCAL_CSV_FILE="$LOCAL_SCRIPT_DIR/datapass_v1_ids.csv"
readonly LOCAL_RUBY_SCRIPT="$LOCAL_SCRIPT_DIR/match_ids_from_csv.rb"
readonly LOCAL_REMOTE_SCRIPT="$LOCAL_SCRIPT_DIR/run_match_ids_remote.sh"

# Remote file paths
readonly REMOTE_CSV_FILE="$REMOTE_TMP/datapass_v1_ids.csv"
readonly REMOTE_RUBY_SCRIPT="$REMOTE_TMP/match_ids_from_csv.rb"
readonly REMOTE_EXEC_SCRIPT="$REMOTE_TMP/run_match_ids_remote.sh"

echo "🚀 === DataPass V1/V2 IDs Matcher - Remote Execution ==="
echo "📅 Started at: $(date)"
echo "🏷️  Session ID: $TIMESTAMP"
echo ""

# Validate local files
echo "🔍 Validating local files..."

if [ ! -f "$LOCAL_CSV_FILE" ]; then
    echo "❌ Error: Local CSV file not found: $LOCAL_CSV_FILE"
    echo "Please ensure the datapass_v1_ids.csv file exists in $LOCAL_SCRIPT_DIR/"
    exit 1
fi

if [ ! -f "$LOCAL_RUBY_SCRIPT" ]; then
    echo "❌ Error: Local Ruby script not found: $LOCAL_RUBY_SCRIPT"
    exit 1
fi

if [ ! -f "$LOCAL_REMOTE_SCRIPT" ]; then
    echo "❌ Error: Local remote script not found: $LOCAL_REMOTE_SCRIPT"
    exit 1
fi

echo "✅ Found local CSV file: $LOCAL_CSV_FILE ($(du -h "$LOCAL_CSV_FILE" | cut -f1))"
echo "✅ Found local Ruby script: $LOCAL_RUBY_SCRIPT"
echo "✅ Found local remote script: $LOCAL_REMOTE_SCRIPT"
echo ""

# Test SSH connection
echo "🔗 Testing SSH connection to $REMOTE_HOST..."
if ! ssh -o ConnectTimeout=10 "$REMOTE_HOST" "echo 'SSH connection successful'" > /dev/null 2>&1; then
    echo "❌ Error: Cannot connect to $REMOTE_HOST via SSH"
    echo "Please ensure SSH is properly configured and you can connect to the remote host."
    exit 1
fi
echo "✅ SSH connection to $REMOTE_HOST successful"
echo ""

# Upload files to remote server
echo "📤 Uploading files to remote server..."

echo "   📤 Uploading CSV file..."
scp "$LOCAL_CSV_FILE" "$REMOTE_HOST:$REMOTE_CSV_FILE"

echo "   📤 Uploading Ruby script..."
scp "$LOCAL_RUBY_SCRIPT" "$REMOTE_HOST:$REMOTE_RUBY_SCRIPT"

echo "   📤 Uploading remote execution script..."
scp "$LOCAL_REMOTE_SCRIPT" "$REMOTE_HOST:$REMOTE_EXEC_SCRIPT"

echo "   🔧 Making remote script executable..."
ssh "$REMOTE_HOST" "chmod +x $REMOTE_EXEC_SCRIPT"

echo "✅ All files uploaded successfully"
echo ""

# Execute the matching script on remote server
echo "🔄 Executing matching script on remote server..."
echo "═══════════════════════════════════════════════════════════════"

if ssh -t "$REMOTE_HOST" "$REMOTE_EXEC_SCRIPT"; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "✅ Remote execution completed successfully!"
else
    echo "═══════════════════════════════════════════════════════════════"
    echo "❌ Remote execution failed!"
    echo ""
    echo "🧹 Cleaning up remote files..."
    ssh "$REMOTE_HOST" "rm -f $REMOTE_CSV_FILE $REMOTE_RUBY_SCRIPT $REMOTE_EXEC_SCRIPT" || true
    exit 1
fi

echo ""

# Create local results directory
echo "📁 Creating local results directory: $RESULTS_DIR"
mkdir -p "$RESULTS_DIR"

# Download results from remote server
echo "📥 Downloading results from remote server..."

# Temporarily disable exit on error for download section
set +e

# Define the result files to check for
RESULT_FILES=(
    "matched_ids_result.csv"
    "unmatched_v1_ids.csv"
    "extra_demandes.csv"
    "extra_authorizations.csv"
    "ambiguous_demandes_left.csv"
)

downloaded_files=0

for file in "${RESULT_FILES[@]}"; do
    echo "   📥 Downloading $file..."
    if scp "$REMOTE_HOST:/tmp/$file" "$RESULTS_DIR/$file" 2>/dev/null; then
        local_size=$(du -h "$RESULTS_DIR/$file" | cut -f1)
        echo "   ✅ Downloaded $file ($local_size)"
        ((downloaded_files++))
    else
        echo "   ➖ File not found or failed: $file"
    fi
done

# Re-enable exit on error
set -e

echo ""
echo "📊 Downloaded $downloaded_files files"

# Clean up remote files
echo "🧹 Cleaning up remote files..."

# Clean up uploaded files
ssh "$REMOTE_HOST" "rm -f $REMOTE_CSV_FILE $REMOTE_RUBY_SCRIPT $REMOTE_EXEC_SCRIPT" || {
    echo "⚠️  Warning: Some uploaded files could not be cleaned up"
}

# Clean up result files
for file in "${RESULT_FILES[@]}"; do
    ssh "$REMOTE_HOST" "rm -f /tmp/$file" 2>/dev/null || true
done

echo "✅ Remote cleanup completed"
echo ""

# Summary
echo "🎉 === EXECUTION SUMMARY ==="
echo "📅 Completed at: $(date)"
echo "🏷️  Session ID: $TIMESTAMP"
echo "📁 Results directory: $RESULTS_DIR"
echo ""

if [ -d "$RESULTS_DIR" ] && [ "$(ls -A "$RESULTS_DIR" 2>/dev/null)" ]; then
    echo "📄 Downloaded files:"
    ls -la "$RESULTS_DIR"
    echo ""
    echo "📊 Key results:"
    if [ -f "$RESULTS_DIR/matched_ids_result.csv" ]; then
        local_lines=$(wc -l < "$RESULTS_DIR/matched_ids_result.csv")
        echo "   • Main results: $((local_lines - 1)) matched records in matched_ids_result.csv"
    fi
    if [ -f "$RESULTS_DIR/unmatched_v1_ids.csv" ]; then
        local_unmatched=$(wc -l < "$RESULTS_DIR/unmatched_v1_ids.csv")
        echo "   • Unmatched IDs: $((local_unmatched - 1)) in unmatched_v1_ids.csv"
    fi
    if [ -f "$RESULTS_DIR/extra_demandes.csv" ]; then
        local_extra_d=$(wc -l < "$RESULTS_DIR/extra_demandes.csv")
        echo "   • Extra demandes: $((local_extra_d - 1)) in extra_demandes.csv"
    fi
    if [ -f "$RESULTS_DIR/extra_authorizations.csv" ]; then
        local_extra_a=$(wc -l < "$RESULTS_DIR/extra_authorizations.csv")
        echo "   • Extra authorizations: $((local_extra_a - 1)) in extra_authorizations.csv"
    fi
else
    echo "⚠️  No result files were downloaded"
    exit 1
fi

echo ""
echo "✅ Remote matching execution completed successfully!"
echo "🔍 Check the results in: $RESULTS_DIR" 