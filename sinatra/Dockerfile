FROM alpine:edge
MAINTAINER Jon Jagger <jon@jaggersoft.com>

COPY Gemfile    /app/
COPY prepare.sh /app/
WORKDIR         /app/
RUN [ "/app/prepare.sh" ]
