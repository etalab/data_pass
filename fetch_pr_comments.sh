#!/bin/bash

REPO="etalab/data_pass"
PR_NUMBER="1274"
OUTPUT_FILE="pr-today.json"

# Get latest review date
LATEST_REVIEW_DATE=$(gh api "repos/$REPO/pulls/$PR_NUMBER/reviews" --paginate | jq -r '[.[].submitted_at] | sort | last | split("T")[0]')

echo "Latest review date: $LATEST_REVIEW_DATE"

# Get all review comments from that date
gh api "repos/$REPO/pulls/$PR_NUMBER/comments" --paginate | \
  jq --arg date "$LATEST_REVIEW_DATE" '[.[] | select(.created_at | startswith($date))]' > "$OUTPUT_FILE"

echo "Comments count: $(jq length $OUTPUT_FILE)"
