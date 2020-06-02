#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=reports
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com
# ENDPOINTURL=http://localhost:8000

ARG1="$1"
ARG2="$2"
ARG3="$3"

ID=$ARG1
Details=$ARG2
UPDATEVAL=$ARG3
UPDATEKEY="Status#Date"

aws dynamodb update-item --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --key '{"ReportID":{"S":"'$ID'"},"ReportDetails":{"S":"'$Details'"}}' \
    --update-expression "SET #q = :q " \
    --expression-attribute-names '{"#q": "'$UPDATEKEY'" }'  \
    --expression-attribute-values '{":q" : {"S":"'$UPDATEVAL'"}}'  \
    --return-consumed-capacity 'INDEXES' \
    --output json \
    --query '{"Consumed WCUs ":ConsumedCapacity}'
