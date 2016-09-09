#!/bin/sh
./build.sh && docker run --rm cyberdojo/differ sh -c "cd test/lib && ./run.sh"
