#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart


ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com
# ENDPOINTURL=http://localhost:8000


aws dynamodb put-item --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --item file://newitem.json \
    --return-consumed-capacity 'TOTAL' \
    --output json \
    --query '{"Consumed WCUs ":ConsumedCapacity.CapacityUnits}'

