#!/bin/sh

export RACK_ENV='production'

# server/test/src/run.sh needs bash
apk --update add ruby ruby-dev ruby-io-console ruby-bundler git bash

echo 'gem: --no-document' > ~/.gemrc #http://stackoverflow.com/questions/1381725

apk --update \
        add --virtual build-dependencies \
          build-base \
        && bundle install && gem clean \
        && apk del build-dependencies

rm -vrf /var/cache/apk/*
rm -v ${0}
