#!/usr/bin/env bash

create_succeeding_test() {
  local name="$1"
  mkdir -p $(dirname ${name})
  cat << END > ${name}
#!/usr/bin/env bash
exit 0
END
  chmod 755 ${name}
}

create_failing_test() {
  local name="$1"
  mkdir -p $(dirname ${name})
  cat << END > ${name}
#!/usr/bin/env bash
exit 1
END
  chmod 755 ${name}
}
