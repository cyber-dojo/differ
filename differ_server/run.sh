#!/bin/sh

ID=$(docker run -p 4567:4567 -d differ_server)
echo ${ID}
