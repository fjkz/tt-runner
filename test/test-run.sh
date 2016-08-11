#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/run1.sh
create_succeeding_test ${WORKDIR}/run2.sh
create_failing_test    ${WORKDIR}/run3.sh
create_succeeding_test ${WORKDIR}/run4.sh

set +e
OUT=$(tt-runner.py ${WORKDIR})
set -e

[[ ${OUT} == "1..4
ok 1 run1.sh # 0 sec
ok 2 run2.sh # 0 sec
not ok 3 run3.sh # 0 sec
ok 4 run4.sh # SKIP
# skipped because run3.sh did not succeed." ]]
