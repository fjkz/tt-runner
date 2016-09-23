#!/usr/bin/env bash

MYNAME=$(readlink -f "${BASH_SOURCE:-$0}")
MYDIR=$(cd -P -- $(dirname -- "${MYNAME}"); pwd)
cd "${MYDIR}"

export PATH="../bin:${PATH}"
export WORKDIR="/tmp/tt-runner-tests"
export CONFDIR="${MYDIR}/conf"
rm -rf result
ttap scripts -o result \
  --randomize --multiply-preconditioning "$@"
