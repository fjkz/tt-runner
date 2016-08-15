#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_failing_test ${WORKDIR}/test2.sh
create_succeeding_test ${WORKDIR}/test3.sh
create_succeeding_test ${WORKDIR}/test4.sh

set +e
OUT=$(tt-runner ${WORKDIR} --stop-on-failure)
set -e

[[ ${OUT} == "1..4
ok 1 test1.sh
not ok 2 test2.sh
ok 3 test3.sh # SKIP
ok 4 test4.sh # SKIP" ]]
