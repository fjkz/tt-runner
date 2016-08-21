#!/usr/bin/env bash

set -eux

mkdir ${WORKDIR}/test-loop
ln -s ${WORKDIR}/test-loop ${WORKDIR}/test-loop/test-loop

set +e

# check do not start inifinity-loop
tt-runner ${WORKDIR}
if [[ $? == 0 ]]; then
  exit 1
fi
