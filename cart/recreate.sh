#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart

# ENDPOINTURL=http://localhost:8000
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com

# read -n1 -r -p "Warning! You are going to delete your DynamoDB table $TABLENAME if it exists! press any key to continue..." key

aws dynamodb delete-table --table-name $TABLENAME --region $REGION \
    --endpoint-url $ENDPOINTURL \
    --output json --query '{"Deleting ":TableDescription.TableName}'

aws dynamodb wait table-not-exists --table-name $TABLENAME --region $REGION \
    --endpoint-url $ENDPOINTURL \
    --output json --query '{"Table ":TableDescription.TableName, "Status:":TableDescription.TableStatus }'


aws dynamodb create-table --cli-input-json file://table.json --region $REGION \
    --endpoint-url $ENDPOINTURL \
    --output json --query '{"New Table":TableDescription.TableName, "Status   ":TableDescription.TableStatus }'

aws dynamodb wait table-exists --table-name $TABLENAME --region $REGION --endpoint-url $ENDPOINTURL


