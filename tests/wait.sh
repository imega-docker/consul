#!/usr/bin/env bash

MOCK_SERVER_CONSUL=$1

while [[ "`curl -s http://$MOCK_SERVER_CONSUL/v1/status/leader --write-out %{http_code} --silent --output /dev/null`" != "200" || "`curl -s http://$MOCK_SERVER_CONSUL/v1/status/leader`" == "\"\"" ]]; do \
    echo "."; sleep 0.3; \
done
