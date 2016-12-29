#!/usr/bin/env bash

. ./functions.sh

set -eux

create_failing_test ${WORKDIR}/test1.sh

set +e
OUT=$(ttap ${WORKDIR} --format tap)
if [[ $? == 0 ]]; then
  exit 1
fi
set -e

[[ ${OUT} == \
"not ok 1 test1.sh
1..1" ]]
