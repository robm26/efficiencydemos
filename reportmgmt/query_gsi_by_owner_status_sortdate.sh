#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=reports
INDEX=StatusDate-by-OwnerID

# ENDPOINTURL=http://localhost:8000
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com

OWNER="$1"
STATUS="$2"


aws dynamodb query --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --index-name $INDEX \
    --key-condition-expression "#p = :p and begins_with (#q,:q)" \
    --expression-attribute-names '{"#p": "OwnerID", "#q": "Status#Date" }'  \
    --expression-attribute-values '{":p" : {"S":"'$OWNER'"}, ":q" : {"S":"'$STATUS'#" } }'  \
    --return-consumed-capacity 'TOTAL' \
    --output json

