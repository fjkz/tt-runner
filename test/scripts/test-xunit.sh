#!/usr/bin/env bash

. ./functions.sh

set -eux

create_succeeding_test ${WORKDIR}/before1.sh
create_failing_test ${WORKDIR}/before2.sh
create_succeeding_test ${WORKDIR}/test1.sh
create_succeeding_test ${WORKDIR}/after.sh

OUT=$(ttap ${WORKDIR} --format xunit) || :

[[ ${OUT} == ".FS.

Failures:
 - before2.sh

4 cases, 1 failures, 1 skipped" ]]
