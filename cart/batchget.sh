#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart
ARG1="$1"


# ENDPOINTURL=http://localhost:8000
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com


ITEMSFILE=$ARG1

if [ -z "$ITEMSFILE" ]
then
      ITEMSFILE="cartproduct.json"
      echo Querying $TABLENAME for Partition Key $PK
fi


aws dynamodb batch-get-item --region $REGION --endpoint-url $ENDPOINTURL \
    --request-items file://$ITEMSFILE \
    --return-consumed-capacity 'TOTAL' \
    --output json \
    --query '{"Item Keys": Responses.ShoppingCart[*].[*],  "Consumed RCUs ":ConsumedCapacity}'
