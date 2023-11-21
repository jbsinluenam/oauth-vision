#!/bin/bash

# This script returns a JWT (signed with HMAC-SHA256 algorithm) when
# a valid userid / password is provided

echo "content-type: text/plain"

# Debugging output
# echo "HTTP_AUTHORIZATION: $HTTP_AUTHORIZATION"
# echo "CRED: $CRED"
# echo "USERID: $USERID"
# echo "PASSWORD: $PASSWORD"

if [ -z "$HTTP_AUTHORIZATION" ]
then
    echo "status: 401"
    echo "WWW-Authenticate: Basic realm=\"Please provide user id and password\""
    echo
    echo "Please login"
    exit 1
fi

# Extracts userid/password
CRED=$(echo -n $HTTP_AUTHORIZATION | grep -i basic | sed -E 's/.*[Bb][Aa][Ss][Ii][Cc] (.*)/\1/')
if [ -z "$CRED" ]; then
    echo "status: 401"
    echo "WWW-Authenticate: Basic realm=\"Please provide user id and password\""
    echo
    echo "We only accept BASIC authentication"
    exit 1
fi

# The $CRED variable has content, run base64 decode and extract
echo "status: 200"
echo

USERID=$(echo "$CRED" | base64 -d | cut -f 1 -d ':')
PASSWORD=$(echo "$CRED" | base64 -d | cut -f 2 -d ':')

# Add debug output
# echo "USERID from script: $USERID"
# echo "PASSWORD from script: $PASSWORD"

# Check if the username:password combination exists in the passwd_plain.txt file
if grep -q "^${USERID}:${PASSWORD}$" passwd_plain.txt; then
    # Valid credentials - create JWT token
    HEADER='{"alg":"HS256","typ":"JWT"}'
    PAYLOAD="{\"id\":\"${USERID}\",\"exp\":\"$(( $(date +%s) + 3600 ))\"}"

    # Base64 encode header and payload for JWT
    B64_HEADER=$(echo -n "$HEADER" | base64 | tr '+/' '-_' | tr -d '=')
    B64_PAYLOAD=$(echo -n "$PAYLOAD" | base64 | tr '+/' '-_' | tr -d '=')

    # Generate HMAC-SHA256 signature
    SIGNATURE=$(echo -n "${B64_HEADER}.${B64_PAYLOAD}" \
        | openssl dgst -sha256 -hmac "here_is_my_secret" -binary \
        | base64 | tr '+/' '-_' | tr -d '=')

    echo "${B64_HEADER}.${B64_PAYLOAD}.${SIGNATURE}"
else
    # Invalid credentials
    echo "status: 401"
    echo "Unauthorized"
    exit 1
fi
