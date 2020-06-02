#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart


ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com
# ENDPOINTURL=http://localhost:8000

# echo Connecting to $ENDPOINTURL
# echo Scanning $TABLENAME with a filter on $PRODUCT

aws dynamodb put-item --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --item file://newitem.json \
    --return-consumed-capacity 'TOTAL' \
    --output json \
    --query '{"Consumed WCUs ":ConsumedCapacity.CapacityUnits}'

#    --projection-expression '#a' \
#    --expression-attribute-names '{ "#a": "'$RETURNATTR'" }'  \
