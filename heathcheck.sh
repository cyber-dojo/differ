#!/bin/bash -Eeu

wget localhost:${PORT}/ready? -q -O - > /dev/null 2>&1
