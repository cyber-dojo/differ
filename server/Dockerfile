FROM alpine:3.4
MAINTAINER Jon Jagger <jon@jaggersoft.com>

RUN apk --update \
  add \
    ruby ruby-io-console bash \
     ruby-dev ruby-bundler

# http://stackoverflow.com/questions/1381725
RUN echo 'gem: --no-document' > ~/.gemrc

ARG app_dir
COPY Gemfile ${app_dir}/
WORKDIR ${app_dir}/

RUN apk --update add --virtual build-dependencies build-base \
  && apk add --no-cache openssl ca-certificates \
  && bundle install && gem clean \
  && apk del build-dependencies \
  && rm -vrf /var/cache/apk/*

# install git 2.10 from edge (it has --compaction-heuristic)
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
  && apk update \
  && apk add git==2.10.2-r0

COPY . ${app_dir}/
RUN export RACK_ENV='production'
EXPOSE 4567



