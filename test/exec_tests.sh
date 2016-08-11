#!/usr/bin/env bash

MYNAME=$(readlink -f "${BASH_SOURCE:-$0}")
MYDIR=$(cd -P -- $(dirname -- "${MYNAME}"); pwd)
cd "${MYDIR}"

export PATH="${MYDIR}/../bin:${PATH}"
export WORKDIR="/tmp/tt-runner-tests"
rm -rf result
tt-runner.py ./ -o result --color --randomize 2>/dev/null
