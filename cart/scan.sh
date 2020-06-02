#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart

# ENDPOINTURL=http://localhost:8000
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com

# echo Connecting to $ENDPOINTURL
# echo Scanning $TABLENAME

aws dynamodb scan --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --return-consumed-capacity 'TOTAL' \
    --output json \
    --query '{"Scanned  Count":ScannedCount, "Returned Count":Count, "Consumed RCUs ":ConsumedCapacity.CapacityUnits}' \
#    --query 'Items[*][PK,SK,Qty]'

