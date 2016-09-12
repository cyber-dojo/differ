#!/bin/sh

# remove images
docker images --quiet --filter dangling=true | xargs docker rmi --force
# remove containers
docker ps     --quiet --filter status=exited | xargs docker rm --force
