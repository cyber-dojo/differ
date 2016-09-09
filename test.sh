#!/bin/sh
./build.sh
docker exec --interactive --tty differ sh -c "cd test/lib && ./run.sh"
