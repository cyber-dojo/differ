FROM cyberdojo/foreman
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# install git 2.10 from edge (it has --compaction-heuristic)
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
  && apk update \
  && apk add git==2.10.2-r0

ARG PORT
ENV PORT=${PORT}
EXPOSE ${PORT}

COPY . /app
