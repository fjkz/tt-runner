#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_succeeding_test ${WORKDIR}/test3.sh

OUT=$(tt-runner ${WORKDIR} --only 2 3)

[[ ${OUT} == "1..3
ok 1 test1.sh # SKIP
ok 2 test2.sh # 0 sec
ok 3 test3.sh # 0 sec" ]]
