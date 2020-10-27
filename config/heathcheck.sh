#!/bin/bash -Eeu

# Default Alpine image does not have curl, but does have wget

wget localhost:${PORT}/ready? -q -O - > /dev/null 2>&1
