#!/bin/sh

docker images --quiet --filter=dangling=true | xargs docker rmi
