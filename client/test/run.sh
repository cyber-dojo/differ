#!/bin/bash

# This is the only shell script that needs bash rather than sh
# It needs it for the (array) handling below.
# Called from test.sh (from outside the docker-container)

if [ ! -f /.dockerenv ]; then
  echo 'FAILED: run.sh is being executed outside of docker-container.'
  echo 'Use test.sh which first calls build.sh'
  exit 1
fi

cov_dir=/tmp/coverage
mkdir ${cov_dir}
test_log=${cov_dir}/test.log

my_dir="$( cd "$( dirname "${0}" )" && pwd )"
cd ${my_dir}/src
files=(*_test.rb)
args=(${*})
ruby -e "%w( ${files[*]} ).map{ |file| './'+file }.each { |file| require file }" -- ${args[@]} | tee ${test_log}
#cd ${my_dir} && ruby ./check_test_results.rb ${test_log} ${cov_dir}/index.html > ${cov_dir}/done.txt
