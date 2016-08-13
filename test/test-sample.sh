#!/usr/bin/env bash

set -xu

ERR=$(tt-runner ../sample 2>&1 1>/dev/null)

set -e

[[ $(echo "${ERR}" | tail -n 5) = '# operations = 32
# succeeded = 29
# failed = 2
# skipped = 1
# time-taken = 0 [sec]' ]]
