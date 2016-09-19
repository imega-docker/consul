#!/usr/bin/env bash

printf '%.0s-' {1..80}
echo

URL=$1

COUNT_TESTS=0
COUNT_TESTS_FAIL=0

assertTrue() {
    testName="$3"
    pad=$(printf '%0.1s' "."{1..80})
    padlength=78

    if [ "$1" != "$2" ]; then
        printf ' %s%*.*s%s' "$3" 0 $((padlength - ${#testName} - 4)) "$pad" "Fail"
        printf ' (expected %s, assertion %s)\n' "$1" "$2"
        let "COUNT_TESTS_FAIL++"
    else
        printf ' %s%*.*s%s\n' "$3" 0 $((padlength - ${#testName} - 2)) "$pad" "Ok"
        let "COUNT_TESTS++"
    fi
}

testDbname() {
    ACTUAL=$(curl --silent http://$URL/v1/kv/service/mysql/dbname?raw)

    assertTrue "db-name" $ACTUAL "$FUNCNAME"
}

testHost() {
    ACTUAL=$(curl --silent http://$URL/v1/kv/service/mysql/host?raw)

    assertTrue "mysql-server" $ACTUAL "$FUNCNAME"
}

testPassword() {
    ACTUAL=$(curl --silent http://$URL/v1/kv/service/mysql/password?raw)

    assertTrue "p@55w0rd" $ACTUAL "$FUNCNAME"
}

testPort() {
    ACTUAL=$(curl --silent http://$URL/v1/kv/service/mysql/port?raw)

    assertTrue "3306" $ACTUAL "$FUNCNAME"
}

testUser() {
    ACTUAL=$(curl --silent http://$URL/v1/kv/service/mysql/user?raw)

    assertTrue "root" $ACTUAL "$FUNCNAME"
}

while [[ "`curl -s http://$URL/v1/status/leader --write-out %{http_code} --silent --output /dev/null`" != "200" || "`curl -s http://$URL/v1/status/leader`" == "\"\"" ]]; do \
    sleep 0.3; \
done

sleep 1;

testDbname
testHost
testPassword
testPort
testUser

printf '%.0s-' {1..80}
echo
printf 'Total test: %s, fail: %s\n\n' "$COUNT_TESTS" "$COUNT_TESTS_FAIL"

if [ $COUNT_TESTS_FAIL -gt 0 ]; then
    exit 1
fi

exit 0
