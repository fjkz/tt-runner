#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/pre.sh
create_succeeding_test ${WORKDIR}/setup.sh
create_succeeding_test ${WORKDIR}/1.test
create_succeeding_test ${WORKDIR}/teardown.sh
create_succeeding_test ${WORKDIR}/post.sh

OUT=$(tt-runner ${WORKDIR} --tap \
  --init-regex 'pre' \
  --before-regex 'setup' \
  --test-regex '.+\.test' \
  --after-regex 'teardown' \
  --final-regex 'post')

[[ ${OUT} == \
"ok 1 pre.sh
ok 2 setup.sh
ok 3 1.test
ok 4 teardown.sh
ok 5 post.sh
1..5" ]]
