#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/run1.sh
create_succeeding_test ${WORKDIR}/run2.sh
create_failing_test    ${WORKDIR}/run3.sh
create_succeeding_test ${WORKDIR}/run4.sh

set +e
OUT=$(tt-runner ${WORKDIR} --tap)
set -e

[[ ${OUT} == "1..4
ok 1 run1.sh
ok 2 run2.sh
not ok 3 run3.sh
ok 4 # SKIP run4.sh
# depending operation did not succeed: run3.sh" ]]
