#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_failing_test ${WORKDIR}/test2.sh

set +e
ERR=$(ttap ${WORKDIR} --print-log -o ${WORKDIR}/result 2>&1 1>/dev/null)
set -e

[[ $(head -n 7 ${WORKDIR}/result/test1.sh.out) == "file: test1.sh

--- output start ---
OK
--- output end ---

status code: 0" ]]
[[ $(head -n 7 ${WORKDIR}/result/test2.sh.out) == "file: test2.sh

--- output start ---
NOT OK
--- output end ---

status code: 1" ]]
[[ $(cat ${WORKDIR}/result/result.txt) == \
"ok 1 test1.sh
not ok 2 test2.sh
1..2" ]]
