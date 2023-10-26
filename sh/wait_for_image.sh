#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SH_DIR="${ROOT_DIR}/sh"

# TODO: wait for image to be pulled from dockerhub in repeating 10s probe
#       for maximum of 1 min, then give up with error
sleep 60