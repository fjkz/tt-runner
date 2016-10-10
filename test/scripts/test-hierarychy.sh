#!/usr/bin/env bash

set -eux

mkdir ${WORKDIR}/before
touch ${WORKDIR}/before/test.sh

set +e
out=$(ttap ${WORKDIR} 2>&1)
set -e

[[ $out == \
"ttap: before-node can not have a test-node child: ${WORKDIR}/before" ]]
