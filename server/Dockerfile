FROM alpine:edge
MAINTAINER Jon Jagger <jon@jaggersoft.com>

COPY Gemfile    /app/
COPY prepare.sh /app/
COPY Procfile   /app/
COPY config.ru  /app/
COPY src/       /app/src/
COPY test/      /app/test/

WORKDIR         /app/
RUN [ "/app/prepare.sh" ]

EXPOSE 4567
CMD [ "foreman", "start", "-d", "/app" ]
