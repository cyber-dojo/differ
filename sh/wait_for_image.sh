#!/usr/bin/env bash
set -Eeu

export ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SH_DIR="${ROOT_DIR}/sh"

# TODO: wait for image to be pulled from dockerhub in repeating probe
#       for maximum of 5 mins, then give up with error
sleep 120