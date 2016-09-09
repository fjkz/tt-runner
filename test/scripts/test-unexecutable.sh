#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh
chmod 644 ${WORKDIR}/test1.sh

OUT=$(tt-runner ${WORKDIR} --tap)

[[ ${OUT} == "1..1
ok 1 test1.sh # SKIP
# test1.sh is not executable." ]]
