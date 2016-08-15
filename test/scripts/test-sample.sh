#!/usr/bin/env bash

. ${CONFDIR}/config.sh

set -xu

ERR=$(tt-runner ${SAMPLE_DIR} 2>&1 1>/dev/null)

set -e

[[ $(echo "${ERR}" | tail -n 11) = '---
operations       : 32
succeeded        : 29
failed           : 2
skipped          : 1
time taken [sec] : 0

FAILURE

- 28 test-simple/test_not_ok.sh
- 30 test-skip/before.sh' ]]
