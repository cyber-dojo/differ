FROM alpine:3.4
MAINTAINER Jon Jagger <jon@jaggersoft.com>
# See https://blog.codeship.com/build-minimal-docker-container-ruby-apps/

ENV BUILD_PACKAGES bash curl-dev ruby-dev build-base
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler

RUN apk update && \
    apk upgrade && \
    apk add $BUILD_PACKAGES && \
    apk add $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

RUN mkdir /usr/app
WORKDIR /usr/app

COPY Gemfile /usr/app/
RUN bundle install
