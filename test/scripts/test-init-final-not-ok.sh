#!/usr/bin/env bash

set -eux

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_failing_test ${WORKDIR}/init.sh
create_succeeding_test ${WORKDIR}/final.sh

set +e
OUT=$(tt-runner ${WORKDIR})
set -e

[[ ${OUT} == "1..4
not ok 1 init.sh
ok 2 test1.sh # SKIP
# 1 init.sh did not succeed.
ok 3 test2.sh # SKIP
# 1 init.sh did not succeed.
ok 4 final.sh" ]]
