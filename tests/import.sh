#!/usr/bin/env bash

MOCK_SERVER_CONSUL=$1

FIXTURES=$(find fixtures/consul -type f -path "*/v1/kv/*" -a -name *.json)
while IFS=';' read -ra ADDR; do
    for i in "${ADDR[@]}"; do
        DIRNAME=$(dirname $i)
        VALUE=$(cat "$i")
        curl -s -X PUT -d "$VALUE" http://$MOCK_SERVER_CONSUL${DIRNAME:15}
        echo " - "${DIRNAME:15}
    done
done <<< "$FIXTURES"

FIXTURES=$(find fixtures/consul -type f -path "*/v1/catalog/*" -a -name *.json)
while IFS=';' read -ra ADDR; do
    for i in "${ADDR[@]}"; do
        DIRNAME=$(dirname $i)
        VALUE=$(cat "$i" | jq -c .)
        curl -s -X PUT -d "$VALUE" http://$MOCK_SERVER_CONSUL${DIRNAME:15}
        echo " - "${DIRNAME:15}
    done
done <<< "$FIXTURES"
