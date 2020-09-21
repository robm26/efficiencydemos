#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart
ARG1="$1"
ARG2="$2"

# ENDPOINTURL=http://localhost:8000
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com

INDEX=$ARG1
PK=$ARG2


if [ -z "$ARG1" ]
then
      PK="Cart1"
      echo Querying $TABLENAME for Partition Key $PK
fi


aws dynamodb query --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --index-name $INDEX \
    --key-condition-expression "#p = :p" \
    --expression-attribute-names '{"#p": "ProductName" }'  \
    --expression-attribute-values '{":p" : {"S":"'$PK'"}}'  \
    --return-consumed-capacity 'TOTAL' \
    --output json \
    --query '{"Scanned  Count":ScannedCount, "Returned Count":Count, "Consumed RCUs ":ConsumedCapacity.CapacityUnits}' \
#    --query 'Items[*][PK,SK]'


