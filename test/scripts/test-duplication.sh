#!/usr/bin/env bash

set -eux

touch ${WORKDIR}/test-run.sh

set +e
out=$(ttap ${WORKDIR} --run-regex '.*run' 2>&1)
set -e

[[ $out == \
"ttap: test-run.sh is in both of test-node and run-node" ]]
