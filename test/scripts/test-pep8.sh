#!/usr/bin/env bash

. ${CONFDIR}/config.sh

if command -v pep8; then
  set -eu
  pep8 ${BIN_DIR}/tt-runner
fi
