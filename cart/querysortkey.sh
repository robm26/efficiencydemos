#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart
ARG1="$1"
ARG1="$2"

# ENDPOINTURL=http://localhost:8000
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com


PK=$ARG1
SK=$ARG2


if [ -z "$ARG2" ]
then
    SK="Product400"

    if [ -z "$ARG1" ]
    then
          PK="Cart1"
          echo Querying $TABLENAME for Partition Key $PK
    fi

fi


aws dynamodb query --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --key-condition-expression "#p = :p and #s = :s" \
    --expression-attribute-names '{"#p": "PK", "#s": "SK" }'  \
    --expression-attribute-values '{":p" : {"S":"'$PK'"}, ":s" : {"S":"'$SK'"}}'  \
    --return-consumed-capacity 'TOTAL' \
    --output json \
    --query '{"Scanned  Count":ScannedCount, "Returned Count":Count, "Consumed RCUs ":ConsumedCapacity.CapacityUnits}' \
#    --query 'Items[*][PK,SK]'


