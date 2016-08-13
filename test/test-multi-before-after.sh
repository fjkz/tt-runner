#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_succeeding_test ${WORKDIR}/before1.sh
create_succeeding_test ${WORKDIR}/before2.sh
create_succeeding_test ${WORKDIR}/after1.sh
create_succeeding_test ${WORKDIR}/after2.sh
create_succeeding_test ${WORKDIR}/before-all1.sh
create_succeeding_test ${WORKDIR}/before-all2.sh
create_succeeding_test ${WORKDIR}/after-all1.sh
create_succeeding_test ${WORKDIR}/after-all2.sh

OUT=$(tt-runner ${WORKDIR})

[[ ${OUT} == "1..14
ok 1 before-all1.sh
ok 2 before-all2.sh
ok 3 before1.sh
ok 4 before2.sh
ok 5 test1.sh
ok 6 after2.sh
ok 7 after1.sh
ok 8 before1.sh
ok 9 before2.sh
ok 10 test2.sh
ok 11 after2.sh
ok 12 after1.sh
ok 13 after-all2.sh
ok 14 after-all1.sh" ]]
