#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart
ARG1="$1"
ARG2="$2"
ARG3="$3"


# ENDPOINTURL=http://localhost:8000
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com

PK=$ARG1
SK=$ARG2

if [ -z "$SK" ]
then
    SK="Product500"

    if [ -z "$PK" ]
    then
          PK="Customer5"
          echo Deleting Item $PK:$SK
    fi
fi

NEWITEM='{"PK":{"S":"'$PK'"},"SK":{"S":"'$SK'"},"Qty":{"N":"15"}}'

# echo Connecting to $ENDPOINTURL
# echo Scanning $TABLENAME with a filter on $SK

aws dynamodb delete-item --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --key '{"PK":{"S":"'$PK'"},"SK":{"S":"'$SK'"}}' \
    --return-consumed-capacity 'TOTAL' \
    --output json \
    --query '{"Consumed WCUs ":ConsumedCapacity}'

#    --projection-expression '#a' \
#    --expression-attribute-names '{ "#a": "'$RETURNATTR'" }'  \
