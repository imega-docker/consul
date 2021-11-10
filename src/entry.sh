#!/usr/bin/env bash
# set -x

MOCK_SERVER_CONSUL="127.0.0.1:8500"

function import() {
    FIXTURES=$(find /data -type f -path "*/v1/kv/*" -a -name *.json)
    while IFS=';' read -ra ADDR; do
        for i in "${ADDR[@]}"; do
            DIRNAME=$(dirname $i)
            VALUE=$(cat "$i")
            curl -s -X PUT -d "$VALUE" http://$MOCK_SERVER_CONSUL${DIRNAME:14}
            echo " - "${DIRNAME:5}
        done
    done <<< "$FIXTURES"

    FIXTURES=$(find /data -type f -path "*/v1/catalog/*" -a -name *.json)
    while IFS=';' read -ra ADDR; do
        for i in "${ADDR[@]}"; do
            DIRNAME=$(dirname $i)
            VALUE=$(cat "$i" | jq -c .)
            curl -s -X PUT -d "$VALUE" http://$MOCK_SERVER_CONSUL${DIRNAME:14}
            echo " - "${DIRNAME:5}
        done
    done <<< "$FIXTURES"
}

while `sleep 0.3;true`; do \
    if [[ `consul info | grep -e "leader = true" -e "state = Leader" | tr '\t\n' ' ' | sed 's/ //g'` == "leader=truestate=Leader" ]]; then \
        import; \
        break; \
    fi; \
done &

consul agent -client=0.0.0.0 -dev
