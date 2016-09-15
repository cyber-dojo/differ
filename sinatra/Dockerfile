FROM alpine:edge
MAINTAINER Jon Jagger <jon@jaggersoft.com>

RUN  mkdir      /usr/app
WORKDIR         /usr/app
COPY Gemfile    /usr/app/
COPY prepare.sh /usr/app/

RUN [ "/usr/app/prepare.sh" ]
