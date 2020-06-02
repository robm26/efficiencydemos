#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart
ARG1="$1"
ARG2="$2"

# ENDPOINTURL=http://localhost:8000
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com


PK=$ARG1
PRODUCTNAME=$ARG2


if [ -z "$ARG2" ]
then
    PRODUCTNAME="Orange"

    if [ -z "$ARG1" ]
    then
          PK="Cart1"
          echo Querying $TABLENAME for Partition Key $PK and filtering on $PRODUCTNAME
    fi

fi

# echo Connecting to $ENDPOINTURL
# echo Scanning $TABLENAME with a filter on $PRODUCT

aws dynamodb query --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --key-condition-expression "#p = :p" \
    --filter-expression "#s = :s" \
    --expression-attribute-names '{"#p": "PK", "#s": "ProductName" }'  \
    --expression-attribute-values '{":p" : {"S":"'$PK'"}, ":s" : {"S":"'$PRODUCTNAME'"}}'  \
    --return-consumed-capacity 'TOTAL' \
    --output json \
    --query '{"Scanned  Count":ScannedCount, "Returned Count":Count, "Consumed RCUs ":ConsumedCapacity.CapacityUnits}' \
#    --query 'Items[*][PK,SK]'


