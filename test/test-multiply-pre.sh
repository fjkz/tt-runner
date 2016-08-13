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

OUT=$(tt-runner ${WORKDIR} --multiply-preconditioning)

[[ ${OUT} == "1..18
ok 1 before-all1.sh
ok 2 before-all2.sh
ok 3 before-all1.sh
ok 4 before-all2.sh
ok 5 before1.sh
ok 6 before2.sh
ok 7 before1.sh
ok 8 before2.sh
ok 9 test1.sh
ok 10 after2.sh
ok 11 after1.sh
ok 12 before1.sh
ok 13 before2.sh
ok 14 test2.sh
ok 15 after2.sh
ok 16 after1.sh
ok 17 after-all2.sh
ok 18 after-all1.sh" ]]
