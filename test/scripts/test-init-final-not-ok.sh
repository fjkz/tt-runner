#!/usr/bin/env bash

set -eux

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_failing_test ${WORKDIR}/init.sh
create_succeeding_test ${WORKDIR}/final.sh

set +e
OUT=$(tt-runner ${WORKDIR} --tap)
set -e

[[ ${OUT} == "1..4
not ok 1 init.sh
ok 2 test1.sh # SKIP
# depending operation did not succeed: init.sh
ok 3 test2.sh # SKIP
# depending operation did not succeed: init.sh
ok 4 final.sh" ]]
