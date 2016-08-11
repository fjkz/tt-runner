#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_succeeding_test ${WORKDIR}/before.sh
create_succeeding_test ${WORKDIR}/after.sh

OUT=$(tt-runner.py ${WORKDIR})

[[ ${OUT} == "1..6
ok 1 before.sh # 0 sec
ok 2 test1.sh # 0 sec
ok 3 after.sh # 0 sec
ok 4 before.sh # 0 sec
ok 5 test2.sh # 0 sec
ok 6 after.sh # 0 sec" ]]
