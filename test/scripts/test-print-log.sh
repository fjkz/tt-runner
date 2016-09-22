#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_failing_test ${WORKDIR}/test2.sh

set +e
ERR=$(ttap ${WORKDIR} --print-log -o ${WORKDIR}/result 2>&1 1>/dev/null)
set -e

[[ $(cat ${WORKDIR}/result/test1.sh.out) == "OK" ]]
[[ $(cat ${WORKDIR}/result/test2.sh.out) == "NOT OK" ]]
[[ $(cat ${WORKDIR}/result/result.txt) == \
"ok 1 test1.sh
not ok 2 test2.sh
1..2" ]]
