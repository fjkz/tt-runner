#!/usr/bin/env bash

set -eux

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_failing_test ${WORKDIR}/before-all.sh
create_succeeding_test ${WORKDIR}/after-all.sh

set +e
OUT=$(tt-runner.py ${WORKDIR})
set -e

[[ ${OUT} == "1..4
not ok 1 before-all.sh # 0 sec
ok 2 test1.sh # SKIP
# skipped because before-all.sh did not succeed.
ok 3 test2.sh # SKIP
# skipped because before-all.sh did not succeed.
ok 4 after-all.sh # 0 sec" ]]
