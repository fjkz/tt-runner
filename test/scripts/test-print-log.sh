#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_failing_test ${WORKDIR}/test2.sh

set +e
ERR=$(tt-runner ${WORKDIR} --print-log -o ${WORKDIR}/result 2>&1 1>/dev/null)
set -e

[[ $(echo "${ERR}" | head -n 6) == "
** run test1.sh **
OK

** run test2.sh **
NOT OK" ]]

[[ $(cat ${WORKDIR}/result/1.test1.sh.out) == "OK" ]]
[[ $(cat ${WORKDIR}/result/2.test2.sh.out) == "NOT OK" ]]
