#!/usr/bin/env bash

MYNAME=$(readlink -f "${BASH_SOURCE:-$0}")
MYDIR=$(cd -P -- $(dirname -- "${MYNAME}"); pwd)
cd "${MYDIR}"

export PATH="${MYDIR}/../bin:${PATH}"
export WORKDIR="/tmp/tt-runner-tests"
rm -rf result
tt-runner ./ -o result --color --randomize --multiply-pre-post 2>/dev/null
