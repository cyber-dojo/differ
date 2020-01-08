#!/bin/bash -Eeu

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

#echo
#echo Currently...
#${MY_DIR}/git-diff.sh

#echo
#option=--diff-algorithm=minimal
#option=--diff-algorithm=histogram
#echo ${option}
#${MY_DIR}/git-diff.sh ${option}

#echo
#option=--word-diff
#echo ${option}
#${MY_DIR}/git-diff.sh ${option}

echo
option='--word-diff-regex=. --diff-algorithm=patience'
echo ${option}
${MY_DIR}/git-diff.sh ${option}

#echo
#option='--word-diff-regex=.|[^[:space:]]'
#echo ${option}
#${MY_DIR}/git-diff.sh ${option}
