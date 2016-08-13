#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_failing_test ${WORKDIR}/before.sh
create_succeeding_test ${WORKDIR}/after.sh

set +e
OUT=$(tt-runner ${WORKDIR})
set -e

[[ ${OUT} == "1..6
not ok 1 before.sh
ok 2 test1.sh # SKIP
# skipped because before.sh did not succeed.
ok 3 after.sh
not ok 4 before.sh
ok 5 test2.sh # SKIP
# skipped because before.sh did not succeed.
ok 6 after.sh" ]]
