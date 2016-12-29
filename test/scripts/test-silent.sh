#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/test1.sh

OUT=$(ttap ${WORKDIR} --format silent)

[[ ${OUT} == "" ]]
