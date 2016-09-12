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

OUT=$(tt-runner ${WORKDIR} --multiply-preconditioning --tap)

[[ ${OUT} == \
"ok 1 init1.sh.1
ok 2 init2.sh.1
ok 3 init1.sh.2
ok 4 init2.sh.2
ok 5 before1.sh.1
ok 6 before2.sh.1
ok 7 before1.sh.2
ok 8 before2.sh.2
ok 9 test1.sh
ok 10 after2.sh.1
ok 11 after1.sh.1
ok 12 before1.sh.3
ok 13 before2.sh.3
ok 14 test2.sh
ok 15 after2.sh.2
ok 16 after1.sh.2
ok 17 final2.sh
ok 18 final1.sh
1..18" ]]
