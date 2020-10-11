#!/bin/bash -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SH_DIR}/build_tagged_images.sh"
source "${SH_DIR}/containers_up.sh"
source "${SH_DIR}/versioner_env_vars.sh"
export $(versioner_env_vars)

readonly TMP_HTML_FILENAME=/tmp/differ-demo.html

build_tagged_images

containers_up

docker exec \
  test-differ-client \
    sh -c 'ruby /differ/app/html_demo.rb' \
      > ${TMP_HTML_FILENAME}

open "file://${TMP_HTML_FILENAME}"

${SH_DIR}/containers_down.sh
