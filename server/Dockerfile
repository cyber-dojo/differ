FROM cyberdojo/sinatra
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# install git 2.11 from edge (it has --compaction-heuristic)
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
  && apk update \
  && apk add git==2.11.1-r0

COPY . /app

ARG PORT
EXPOSE ${PORT}

ENV PORT=${PORT}
CMD [ "./up.sh" ]
