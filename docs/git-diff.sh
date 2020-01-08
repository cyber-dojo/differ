#!/bin/bash -Ee

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly TMP_DIR=$(mktemp -d /tmp/cyber-dojo-differ-word-diff.XXXXXXXXX)
trap "rm -rf ${TMP_DIR}" INT EXIT

readonly OPTION="${1}"

cd ${TMP_DIR}
git init --quiet
git config user.name word-differ
git config user.email word-differ@cyber-dojo.org
cp ${MY_DIR}/file.was ./file
git add .
git commit --allow-empty --all --message 0 --quiet
git tag 0 HEAD
cp ${MY_DIR}/file.now ./file
git add .
git commit --allow-empty --all --message 1 --quiet
git tag 1 HEAD
git diff \
  --find-copies-harder \
  --indent-heuristic \
  --ignore-space-at-eol \
  --no-prefix \
  --unified=99999999999 \
  ${OPTION} \
  0 \
  1 \
  --
