#!/bin/bash

CLIENT_ID='838987397758-cc1a548ld2l1r04td2gmobg25le200p0.apps.googleusercontent.com'
CLIENT_SECRET='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'
REDIRECT_URI='https://learn.operatoroverload.com/~nsinluenam00/lab9/'

# Check if an argument (code) is provided
if [ $# -eq 0 ]; then
  echo "Error: Code parameter is missing."
  exit 1
fi

echo "content-type: application/json"
echo ""

CODE="$1"

#echo "Received CODE: $CODE"

TOKEN=$(curl -X POST "https://oauth2.googleapis.com/token" \
     -d "code=${CODE}" \
     -d "client_id=${CLIENT_ID}" \
     -d "client_secret=${CLIENT_SECRET}" \
     -d "redirect_uri=${REDIRECT_URI}" \
     -d "grant_type=authorization_code")

echo "$TOKEN"

