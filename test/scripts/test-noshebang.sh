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

OUT=$(ttap ${WORKDIR} --format tap) || :

echo "${OUT}" | {
  read line; [[ $line == "not ok 1 test1.sh" ]]
  read line; [[ $line =~ "# [Errno 2] No such file or directory" ]]
  read line; [[ $line == "# Is the shebang correct?" ]]
  read line; [[ $line == "1..1" ]]
}
