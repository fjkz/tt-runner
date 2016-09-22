#!/usr/bin/env bash

set -eux

create_wrong_test() {
  local name="$1"
  mkdir -p $(dirname ${name})
  cat << END > ${name}
#!/no_interpreter
echo OK
exit 0
END
  chmod 755 ${name}
}

create_wrong_test ${WORKDIR}/test1.sh

set +e
OUT=$(ttap ${WORKDIR} --tap)
set -e

[[ ${OUT} == \
"not ok 1 test1.sh
# OSError: [Errno 2] No such file or directory
# Is the shebang correct?
1..1" ]]
