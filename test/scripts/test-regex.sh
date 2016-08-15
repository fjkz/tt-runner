#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/pre.sh
create_succeeding_test ${WORKDIR}/setup.sh
create_succeeding_test ${WORKDIR}/1.t
create_succeeding_test ${WORKDIR}/teardown.sh
create_succeeding_test ${WORKDIR}/post.sh

OUT=$(tt-runner ${WORKDIR} \
  --init-regex 'pre' \
  --before-regex 'setup' \
  --test-regex '.+\.t' \
  --after-regex 'teardown' \
  --final-regex 'post')

[[ ${OUT} == "1..5
ok 1 pre.sh
ok 2 setup.sh
ok 3 1.t
ok 4 teardown.sh
ok 5 post.sh" ]]
