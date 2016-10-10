#!/usr/bin/env bash

set -eux

touch ${WORKDIR}/test.sh
touch ${WORKDIR}/run.sh

set +e
out=$(ttap ${WORKDIR} 2>&1)
set -e

[[ $out == \
"ttap: run-node and other node types can not be in the same directory: ${WORKDIR}" ]]
