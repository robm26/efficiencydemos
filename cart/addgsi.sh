#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart

# ENDPOINTURL=http://localhost:8000
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com


aws dynamodb update-table --table-name "ShoppingCart" \
    --attribute-definitions AttributeName=ProductName,AttributeType=S AttributeName=Price,AttributeType=N \
    --global-secondary-index-updates \
        "[{\"Create\": \
            {\"IndexName\": \"GSI-ProductPrice\", \
             \"KeySchema\":[ \
                 {\"AttributeName\":\"ProductName\",\"KeyType\":\"HASH\"}, \
                 {\"AttributeName\":\"Price\",\"KeyType\":\"RANGE\"} \
                 ], \
        \"Projection\":{\"ProjectionType\":\"ALL\"}}}]" \
    --region $REGION \
    --endpoint-url $ENDPOINTURL \
    --output json --query '{"New Table":TableDescription.TableName, "Status   ":TableDescription.TableStatus }'


