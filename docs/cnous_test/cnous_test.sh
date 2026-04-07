#!/bin/bash

COG_CODES='["92040"]'
MIN_SCHOLARSHIP_LEVEL='0Bis'
CAMPAIGN_YEAR='null'

BASE_URL='https://api-pp.nuonet.fr/statut-boursier'
AUTH_URL='https://acces-pp.nuonet.fr/api-pp/oauth/token?grant_type=client_credentials'

CREDENTIALS=$(echo -n "${CNOUS_CLIENT_ID}:${CNOUS_CLIENT_SECRET}" | base64 -w 0)

TOKEN_RESPONSE=$(curl -s -X POST "$AUTH_URL" \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Accept: application/json' \
  -H "Authorization: Basic $CREDENTIALS")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
echo "Access token obtained."

BODY=$(printf '{"cogCodes":%s,"minScholarshipLevel":"%s","campaignYear":%s}' "$COG_CODES" "$MIN_SCHOLARSHIP_LEVEL" "$CAMPAIGN_YEAR")

RESPONSE=$(curl -s --show-error -w '\n%{http_code}' -X POST "$BASE_URL/v1/scholarship-holder-api-export/create" \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "$BODY" 2>/tmp/curl_error)
CURL_EXIT=$?

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
RESPONSE_BODY=$(echo "$RESPONSE" | head -n -1)

if [ $CURL_EXIT -ne 0 ]; then
  echo "Connection error: $(cat /tmp/curl_error)"
elif [ "$HTTP_CODE" = "201" ]; then
  EXPORT_ID=$(echo "$RESPONSE_BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
  echo "Export ID: $EXPORT_ID"
else
  echo "Error $HTTP_CODE: $RESPONSE_BODY"
fi
