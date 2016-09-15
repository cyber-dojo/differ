#!/bin/sh

# server/test/src/run.sh needs bash
apk --update add ruby ruby-dev ruby-io-console ruby-bundler git bash
rm -v ${0}
