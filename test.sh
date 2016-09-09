#!/bin/sh
docker images --quiet --filter=dangling=true | xargs docker rmi
./build.sh && docker run --rm cyberdojo/differ sh -c "cd test/lib && ./run.sh"
