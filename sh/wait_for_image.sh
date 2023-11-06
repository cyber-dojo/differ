#!/usr/bin/env bash
set -Eu

TAG="$(echo ${GITHUB_SHA} | head -c7)"
MAX_ATTEMPTS=30  # every 10s for 5 minutes
ATTEMPTS=1

until docker pull cyberdojo/differ:${TAG}
do
  sleep 10
  [[ ${ATTEMPTS} -eq ${MAX_ATTEMPTS} ]] && echo "Failed!" && exit 1
  ((ATTEMPTS++))
  echo "Trying docker pull cyberdojo/differ:${TAG} again. Attempt #${ATTEMPTS}"
done
