#!/usr/bin/env bash

REGION=us-east-1
TABLENAME=ShoppingCart
ARG1="$1"
ARG2="$2"
ARG3="$3"
ARG4="$4"

# ENDPOINTURL=http://localhost:8000
ENDPOINTURL=https://dynamodb.$REGION.amazonaws.com


PK=$ARG1
SK=$ARG2
RETURNATTR=$ARG3
CONSISTENCY=$ARG4

PROJECTIONEXPRESSION=""
CRFLAG="--no-consistent-read"

if [ ! -z "$CONSISTENCY" ] && [ "STRONG" = $CONSISTENCY ]
then
    CRFLAG="--consistent-read"
fi


if [ -z "$RETURNATTR" ] || [ "ALL" = $RETURNATTR ] || [ "All" = $RETURNATTR ] || [ "all" = $RETURNATTR ]
then

    if [ -z "$SK" ]
    then
        SK="Product100"

        if [ -z "$PK" ]
        then
              PK="Cart1"
              echo Getting Item $PK:$SK
        fi
    fi
else
    PROJECTIONEXPRESSION="--projection-expression $RETURNATTR"
fi



echo $CRFLAG : $CONSISTENCY
echo $PROJECTIONEXPRESSION

# PROJECTIONEXPRESSION='--projection-expression "#a" --expression-attribute-names  "{ \"#a\": \"DateOrdered\" }"  '


# echo Connecting to $ENDPOINTURL
# echo Scanning $TABLENAME with a filter on $SK

aws dynamodb get-item --region $REGION --endpoint-url $ENDPOINTURL \
    --table-name $TABLENAME \
    --key '{"PK":{"S":"'$PK'"},"SK":{"S":"'$SK'"}}' \
    $PROJECTIONEXPRESSION \
    $CRFLAG \
    --return-consumed-capacity 'TOTAL' \
    --output json \
    --query '{"Item": Item,  "Consumed RCUs ":ConsumedCapacity.CapacityUnits}'


#    --projection-expression '#a' \
#    --expression-attribute-names '{ "#a": "'$RETURNATTR'" }'  \
