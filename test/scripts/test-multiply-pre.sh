#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_succeeding_test ${WORKDIR}/before1.sh
create_succeeding_test ${WORKDIR}/before2.sh
create_succeeding_test ${WORKDIR}/after1.sh
create_succeeding_test ${WORKDIR}/after2.sh
create_succeeding_test ${WORKDIR}/init1.sh
create_succeeding_test ${WORKDIR}/init2.sh
create_succeeding_test ${WORKDIR}/final1.sh
create_succeeding_test ${WORKDIR}/final2.sh

OUT=$(tt-runner ${WORKDIR} --multiply-preconditioning)

[[ ${OUT} == "1..18
ok 1 init1.sh
ok 2 init2.sh
ok 3 init1.sh
ok 4 init2.sh
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
ok 17 final2.sh
ok 18 final1.sh" ]]
