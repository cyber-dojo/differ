#!/bin/bash -Ee

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )"
source ${SH_DIR}/cat_env_vars.sh
export $(cat_env_vars)
${SH_DIR}/build_images.sh
${SH_DIR}/containers_up.sh

TMP_HTML_FILENAME=/tmp/differ-demo.html

docker exec \
  test-differ-client \
    sh -c 'ruby /app/src/html_demo.rb' \
      > ${TMP_HTML_FILENAME}

open "file://${TMP_HTML_FILENAME}"

${SH_DIR}/containers_down.sh
