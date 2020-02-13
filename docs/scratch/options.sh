#!/bin/bash -Eeu

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

#option=--diff-algorithm=minimal
#option='--word-diff-regex=[^[:space:]]'
#option='--word-diff-regex=. --diff-algorithm=minimal'

show()
{
  local -r option="${1}"
  echo
  echo "${option}"
  ${MY_DIR}/git-diff.sh "${option}"
}

show '--diff-algorithm=histogram'
show '--word-diff=porcelain'
show '--word-diff-regex=.'
