#!/usr/bin/env bash
set -Eeu

TAG="$(echo ${GITHUB_SHA} | head -c7)"
MAX_TRIES=30  # every 10s for 5 mins
COUNTER=0
until docker pull cyberdojo/differ:${TAG}
do
  sleep 10
  [[ ${COUNTER} -eq ${MAX_TRIES} ]] && echo "Failed!" && exit 1
  echo "Trying docker pull cyberdojo/differ:${TAG} again. Try #${COUNTER}"
  ((COUNTER++))
done
