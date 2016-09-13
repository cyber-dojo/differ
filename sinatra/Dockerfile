FROM alpine:edge
MAINTAINER Jon Jagger <jon@jaggersoft.com>

ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler
RUN  apk --update add $RUBY_PACKAGES

RUN    mkdir /usr/app
WORKDIR      /usr/app
COPY Gemfile /usr/app/

RUN apk --update add bash

ENV BUILD_PACKAGES ruby-dev build-base
RUN  apk --update \
        add --virtual build-dependencies \
          $BUILD_PACKAGES \
        && bundle install --without development test \
        && apk del build-dependencies
