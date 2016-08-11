#!/usr/bin/env bash

. ./functions.sh

set -eux

create_failing_test ${WORKDIR}/test1.sh

set +e
OUT=$(tt-runner ${WORKDIR})
if [[ $? == 0 ]]; then
  exit 1
fi
set -e

[[ ${OUT} == "1..1
not ok 1 test1.sh # 0 sec" ]]
