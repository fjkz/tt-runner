#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_succeeding_test ${WORKDIR}/test3.sh

OUT=$(ttap ${WORKDIR} --skip-all --tap)

[[ ${OUT} == \
"ok 1 # SKIP test1.sh
ok 2 # SKIP test2.sh
ok 3 # SKIP test3.sh
1..3" ]]
