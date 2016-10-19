FROM alpine:edge
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# server/test/src/run.sh needs bash
# alpine:edge has git 2.10 with --compaction-heuristic
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

# - - - - - - - - - - - - - - - - - - - - - -

COPY . ${app_dir}/
RUN export RACK_ENV='production'
EXPOSE 4567

# - - - - - - - - - - - - - - - - - - - - - -
# alpine:edge has git 2.10 with --compaction-heuristic

RUN apk --update add git
