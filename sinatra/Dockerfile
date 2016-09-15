FROM alpine:edge
MAINTAINER Jon Jagger <jon@jaggersoft.com>

ENV RUBY_PACKAGES ruby ruby-dev ruby-io-console ruby-bundler
RUN  apk --update add $RUBY_PACKAGES

RUN    mkdir /usr/app
WORKDIR      /usr/app
COPY Gemfile /usr/app/

# server/test/src/run.sh needs bash
RUN apk --update add bash

ENV BUILD_PACKAGES build-base
RUN  apk --update \
        add --virtual build-dependencies \
          $BUILD_PACKAGES \
        && bundle install --without development test \
        && apk del build-dependencies

# This creates a server image of ~76MB
# without rack-prof gem ~74MB
# Look into this for a probably smaller image
# https://github.com/sashaegorov/docker-alpine-sinatra