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

[[ ${OUT} == \
"not ok 1 init.sh
ok 2 # SKIP test1.sh
# depending operation did not succeed: init.sh
ok 3 # SKIP test2.sh
# depending operation did not succeed: init.sh
ok 4 final.sh
1..4" ]]
