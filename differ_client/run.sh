#!/bin/sh

ID=$(docker run -p 4568:4568 -d differ_client)
echo ${ID}
