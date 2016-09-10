#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_succeeding_test ${WORKDIR}/test3.sh

mkdir ${WORKDIR}/test4
create_succeeding_test ${WORKDIR}/test4/run1.sh
create_succeeding_test ${WORKDIR}/test4/run2.sh

OUT=$(tt-runner ${WORKDIR} --only test2.sh test4 --tap)

[[ ${OUT} == "1..5
ok 1 # SKIP test1.sh
ok 2 test2.sh
ok 3 # SKIP test3.sh
ok 4 test4/run1.sh
ok 5 test4/run2.sh" ]]
