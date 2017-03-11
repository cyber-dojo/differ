FROM cyberdojo/sinatra
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# install git 2.11 from edge (it has --compaction-heuristic)
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
  && apk update \
  && apk add git==2.11.1-r0

RUN echo "gem 'prometheus-client'" >> /app/Gemfile
RUN apk --update add --virtual build-dependencies build-base \
    && bundle install && gem clean \
    && apk del build-dependencies \
    && rm -vrf /var/cache/apk/*

COPY . /app

ARG PORT
EXPOSE ${PORT}

ENV PORT=${PORT}
CMD [ "./up.sh" ]
