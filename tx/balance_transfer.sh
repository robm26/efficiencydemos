#!/usr/bin/env bash

REGION=us-east-1
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com
# ENDPOINTURL=http://localhost:8000

TXID="$1"
TXIN="$2"

aws dynamodb transact-write-items --region $REGION --endpoint-url $ENDPOINTURL \
    --transact-items file://$TXIN.input \
    --client-request-token $TXID \
    --return-consumed-capacity 'INDEXES' \
    --output json
