#!/bin/bash -Eeu

# Default Alpine image has wget (but not curl)

wget localhost:${PORT}/ready? -q -O - > /dev/null 2>&1
