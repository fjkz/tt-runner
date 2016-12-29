#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
chmod 644 ${WORKDIR}/test1.sh

OUT=$(ttap ${WORKDIR} --format tap) || :

[[ ${OUT} == \
"not ok 1 test1.sh
# test1.sh is not executable.
1..1" ]]
