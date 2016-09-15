#!/bin/sh

export RACK_ENV='production'

apk --update add ruby ruby-dev ruby-io-console ruby-bundler

echo 'gem: --no-document' > ~/.gemrc #http://stackoverflow.com/questions/1381725

apk --update \
        add --virtual build-dependencies \
          build-base \
        && bundle install && gem clean \
        && apk del build-dependencies

rm -vrf /var/cache/apk/*
rm -v ${0}
