FROM cyberdojo/sinatra
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# RUN adduser -D -H differ   ???

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
