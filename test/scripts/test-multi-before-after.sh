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

OUT=$(ttap ${WORKDIR} --format tap)

[[ ${OUT} == \
"ok 1 init1.sh
ok 2 init2.sh
ok 3 before1.sh.1
ok 4 before2.sh.1
ok 5 test1.sh
ok 6 after2.sh.1
ok 7 after1.sh.1
ok 8 before1.sh.2
ok 9 before2.sh.2
ok 10 test2.sh
ok 11 after2.sh.2
ok 12 after1.sh.2
ok 13 final2.sh
ok 14 final1.sh
1..14" ]]
