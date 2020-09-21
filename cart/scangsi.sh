#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart

ARG1="$1"

# ENDPOINTURL=http://localhost:8000
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com

INDEX=$ARG1


aws dynamodb scan --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --index-name $INDEX \
    --return-consumed-capacity 'TOTAL' \
    --output json \
    --query '{"Scanned  Count":ScannedCount, "Returned Count":Count, "Consumed RCUs ":ConsumedCapacity.CapacityUnits}' \
#    --query 'Items[*][PK,SK,Qty]'

