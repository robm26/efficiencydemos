#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart
ARG1="$1"


# ENDPOINTURL=http://localhost:8000
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com


PK=$ARG1


if [ -z "$ARG1" ]
then
      PK="Cart1"
      echo Querying $TABLENAME for Partition Key $PK
fi

# echo Connecting to $ENDPOINTURL
# echo Scanning $TABLENAME with a filter on $PRODUCT

aws dynamodb query --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --key-condition-expression "#p = :p" \
    --expression-attribute-names '{"#p": "PK" }'  \
    --expression-attribute-values '{":p" : {"S":"'$PK'"}}'  \
    --return-consumed-capacity 'TOTAL' \
    --output json \
    --query '{"Scanned  Count":ScannedCount, "Returned Count":Count, "Consumed RCUs ":ConsumedCapacity.CapacityUnits}' \
#    --query 'Items[*][PK,SK]'


