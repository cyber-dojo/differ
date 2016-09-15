#!/bin/sh

MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
FILENAME=`basename ${1}`
${MY_DIR}/../../test.sh ${FILENAME}
