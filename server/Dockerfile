FROM  alpine:latest
LABEL maintainer=jon@jaggersoft.com

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install ruby
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RUN apk --update --no-cache add \
    ruby ruby-dev ruby-bundler \
    bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# install ruby gems
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RUN echo 'gem: --no-document' > ~/.gemrc
COPY Gemfile /app/
WORKDIR /app

RUN apk --update add --virtual build-dependencies build-base \
  && bundle config --global silence_root_warning 1 \
  && bundle install \
  && gem clean \
  && apk del build-dependencies \
  && rm -vrf /var/cache/apk/*

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# setup server
# tar is needed to tar-pipe test coverage out of tmpfs.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

RUN apk --update --no-cache add tar

# install git 2.11 (it has --compaction-heuristic)
# from v3.5 for slightly better diffs.
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.5/main' >> /etc/apk/repositories \
  && apk update \
  && apk add git==2.11.3-r0

COPY . /app
ARG PORT
EXPOSE ${PORT}
ENV PORT=${PORT}
CMD [ "./up.sh" ]
