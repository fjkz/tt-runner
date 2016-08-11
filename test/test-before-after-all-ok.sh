#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_succeeding_test ${WORKDIR}/before-all.sh
create_succeeding_test ${WORKDIR}/after-all.sh

OUT=$(tt-runner ${WORKDIR})

[[ ${OUT} == "1..4
ok 1 before-all.sh # 0 sec
ok 2 test1.sh # 0 sec
ok 3 test2.sh # 0 sec
ok 4 after-all.sh # 0 sec" ]]
