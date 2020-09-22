#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com
# ENDPOINTURL=http://localhost:8000

ARG1="$1"
ARG2="$2"
ARG3="$3"
ARG4="$4"

PK=$ARG1
SK=$ARG2
UPDATEKEY=$ARG3
UPDATEVAL=$ARG4

KEYTYPE="S"

if [ -z "$UPDATEKEY" ]
then
    UPDATEKEY="Qty"
    UPDATEVAL=$RANDOM
fi

re='^[0-9]+$'
if [[ $UPDATEVAL =~ $re ]] ; then
   KEYTYPE="N"

fi


if [ -z "$SK" ]
then
    SK="Product200"

    if [ -z "$PK" ]
    then
          PK="Cart2"
          echo Updating $TABLENAME for $PK:$SK with $UPDATEKEY = $UPDATEVAL
    fi
fi



aws dynamodb update-item --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --key '{"PK":{"S":"'$PK'"},"SK":{"S":"'$SK'"}}' \
    --update-expression "SET #q = :q " \
    --expression-attribute-names '{"#q": "'$UPDATEKEY'" }'  \
    --expression-attribute-values '{":q" : {"'$KEYTYPE'":"'$UPDATEVAL'"}}'  \
    --return-consumed-capacity 'INDEXES' \
    --output json \
    --query '{"Consumed WCUs ":ConsumedCapacity}'
