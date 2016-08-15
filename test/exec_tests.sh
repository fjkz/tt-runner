#!/usr/bin/env bash

MYNAME=$(readlink -f "${BASH_SOURCE:-$0}")
MYDIR=$(cd -P -- $(dirname -- "${MYNAME}"); pwd)
cd "${MYDIR}"

export PATH="${MYDIR}/../bin:${PATH}"
export WORKDIR="/tmp/tt-runner-tests"
export CONFDIR="${MYDIR}/conf"
rm -rf result
tt-runner scripts -o result \
  --color --randomize --multiply-preconditioning 2>/dev/null
