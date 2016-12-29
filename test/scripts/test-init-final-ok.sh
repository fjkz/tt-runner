#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_succeeding_test ${WORKDIR}/init.sh
create_succeeding_test ${WORKDIR}/final.sh

OUT=$(ttap ${WORKDIR} --format tap)

[[ ${OUT} == \
"ok 1 init.sh
ok 2 test1.sh
ok 3 test2.sh
ok 4 final.sh
1..4" ]]
