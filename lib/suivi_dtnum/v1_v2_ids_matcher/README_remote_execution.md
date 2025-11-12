# DataPass V1/V2 IDs Matcher - Remote Execution

This solution allows you to execute the DataPass V1/V2 IDs matching script on a remote server using local CSV files.

## Overview

The solution consists of three main components:

1. **Local orchestration script** (`execute_remote_matching.sh`) - Manages the entire process
2. **Remote Ruby script** (`match_ids_from_csv.rb`) - Performs the actual matching logic
3. **Remote execution script** (`run_match_ids_remote.sh`) - Executes the Ruby script on the remote server

## Prerequisites

- SSH access to the remote server (`watchdoge`)
- The `datapass_v1_ids.csv` file containing the V1 IDs to match
- Proper SSH key configuration for passwordless authentication

## Files Structure

```
lib/suivi_dtnum/v1_v2_ids_matcher/
├── datapass_v1_ids.csv              # Input CSV file with V1 IDs
├── execute_remote_matching.sh       # Main execution script (run this)
├── match_ids_from_csv.rb            # Ruby script for ID matching
├── run_match_ids_remote.sh          # Remote execution wrapper
└── results_YYYYMMDD_HHMMSS/         # Results directory (created after execution)
    ├── matched_ids_result.csv        # Main results file
    ├── unmatched_v1_ids.csv          # Unmatched V1 IDs (if any)
    ├── extra_demandes.csv            # Extra demandes found (if any)
    ├── extra_authorizations.csv      # Extra authorizations found (if any)
    └── ambiguous_demandes_left.csv   # Ambiguous cases (if any)
```

## CSV Input Format

The `datapass_v1_ids.csv` file should have this format:

```csv
N° DataPass
925
934
1016
...
```

- First row is the header (`N° DataPass`)
- Each subsequent row contains one V1 ID (integer)

## Usage

### Basic Execution

Simply run the main script from the project root:

```bash
./lib/suivi_dtnum/v1_v2_ids_matcher/execute_remote_matching.sh
```

### What the Script Does

1. **Validates local files** - Checks that all required files exist
2. **Tests SSH connection** - Ensures connectivity to the remote server
3. **Uploads files** - Transfers CSV data and scripts to the remote server
4. **Executes matching** - Runs the Ruby script via Rails on the remote server
5. **Downloads results** - Retrieves all generated CSV files
6. **Cleanup** - Removes temporary files from the remote server

### Output

The script creates a timestamped results directory with all generated files:

- `matched_ids_result.csv` - Main output with V1 ID → V2 demande/habilitation mappings
- `unmatched_v1_ids.csv` - V1 IDs that couldn't be matched (if any)
- `extra_demandes.csv` - Additional demandes found in V2 system (if any)
- `extra_authorizations.csv` - Additional authorizations found in V2 system (if any)
- `ambiguous_demandes_left.csv` - Cases requiring manual review (if any)

## Output Format

### Main Results (`matched_ids_result.csv`)

```csv
datapass_v1_id,demande_v2_id,habilitation_v2_id
925,1234,5678
934,1235,
1016,1236,5679
...
```

- `datapass_v1_id`: Original V1 ID
- `demande_v2_id`: Matching V2 demande ID (or empty if no match)
- `habilitation_v2_id`: Matching V2 habilitation ID (or empty if no match/multiple matches)

## Error Handling

The script includes comprehensive error handling:

- **File validation** - Checks for required files before execution
- **SSH connectivity** - Verifies remote access before proceeding
- **Remote execution** - Monitors script execution and reports failures
- **Cleanup** - Ensures temporary files are removed even on failure

## Troubleshooting

### SSH Connection Issues

If you encounter SSH connection problems:

```bash
# Test SSH connection manually
ssh watchdoge "echo 'Connection test'"

# Check SSH configuration
cat ~/.ssh/config
```

### Missing Files

Ensure all required files exist:

```bash
ls -la lib/suivi_dtnum/v1_v2_ids_matcher/datapass_v1_ids.csv
ls -la lib/suivi_dtnum/v1_v2_ids_matcher/match_ids_from_csv.rb
ls -la lib/suivi_dtnum/v1_v2_ids_matcher/run_match_ids_remote.sh
```

### Remote Execution Failures

If the remote script fails:

1. Check the Rails application is running
2. Verify database connectivity
3. Check Ruby script syntax
4. Review Rails logs for detailed error messages

## Manual Execution

If you need to run the process manually:

```bash
# 1. Upload files to remote
scp lib/suivi_dtnum/v1_v2_ids_matcher/datapass_v1_ids.csv watchdoge:/tmp/
scp lib/suivi_dtnum/v1_v2_ids_matcher/match_ids_from_csv.rb watchdoge:/tmp/
scp lib/suivi_dtnum/v1_v2_ids_matcher/run_match_ids_remote.sh watchdoge:/tmp/

# 2. Execute on remote
ssh -t watchdoge "chmod +x /tmp/run_match_ids_remote.sh && /tmp/run_match_ids_remote.sh"

# 3. Download results
scp watchdoge:/tmp/matched_ids_result.csv ./
scp watchdoge:/tmp/unmatched_v1_ids.csv ./  # if exists
# ... download other result files as needed

# 4. Cleanup remote
ssh watchdoge "rm -f /tmp/datapass_v1_ids.csv /tmp/match_ids_from_csv.rb /tmp/run_match_ids_remote.sh /tmp/*_result.csv /tmp/unmatched_*.csv /tmp/extra_*.csv /tmp/ambiguous_*.csv"
```

## Security Notes

- Files are temporarily stored in `/tmp/` on the remote server
- All temporary files are cleaned up after execution
- Only CSV data and Ruby scripts are transferred
- No sensitive credentials are stored in scripts 