#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com
# ENDPOINTURL=http://localhost:8000

ARG1="$1"

PK=$ARG1

if [ -z "$ARG1" ]
then
      PK="Cart1"
      echo Scanning $TABLENAME with a filter on $PK
fi

aws dynamodb scan --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --filter-expression "#p = :c" \
    --expression-attribute-names '{"#p": "PK" }'  \
    --expression-attribute-values '{":c" : {"S":"'$PK'"}}'  \
    --return-consumed-capacity 'TOTAL' \
    --output json \
    --query '{"Scanned  Count":ScannedCount, "Returned Count":Count, "Consumed RCUs ":ConsumedCapacity.CapacityUnits}' \
#    --query 'Items[*][PK,SK]'

