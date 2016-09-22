#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/test2.sh
create_failing_test ${WORKDIR}/before.sh
create_succeeding_test ${WORKDIR}/after.sh

set +e
OUT=$(ttap ${WORKDIR} --tap)
set -e

[[ ${OUT} == \
"not ok 1 before.sh.1
ok 2 # SKIP test1.sh
# depending operation did not succeed: before.sh.1
ok 3 after.sh.1
not ok 4 before.sh.2
ok 5 # SKIP test2.sh
# depending operation did not succeed: before.sh.2
ok 6 after.sh.2
1..6" ]]
