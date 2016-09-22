#!/usr/bin/env bash

set -eux

mkdir -p ${WORKDIR}

cat << END > ${WORKDIR}/test1.bats
#!/usr/bin/env bash
echo "1..3"
echo "ok 1 a"
echo "not ok 2 b"
echo "# bbbbb"
echo "ok 3 # SKIP c"
exit 1
END

cat << END > ${WORKDIR}/test2.t
#!/usr/bin/env bash
echo "1..3"
echo "ok 1 - A"
echo "not ok 2 - B"
echo "# bbbbb"
echo "# bbbb"
echo "ok 3 - # skip C"
exit 1
END

cat << END > ${WORKDIR}/test3.t
#!/usr/bin/env bash
echo "1..3"
echo "ok 1 - A"
echo "Bail out! ZZZ"
exit 1
END

chmod 755 ${WORKDIR}/test1.bats
chmod 755 ${WORKDIR}/test2.t
chmod 755 ${WORKDIR}/test3.t

set +e
OUT=$(ttap ${WORKDIR} --tap)
set -e

[[ ${OUT} == \
"ok 1 test1.bats: a
not ok 2 test1.bats: b
# bbbbb
ok 3 # SKIP test1.bats: c
ok 4 test2.t: A
not ok 5 test2.t: B
# bbbbb
# bbbb
ok 6 # SKIP test2.t: C
ok 7 test3.t: A
not ok 8 test3.t
# Bail out! ZZZ
1..8" ]]
