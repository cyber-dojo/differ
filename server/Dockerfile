FROM alpine:edge
MAINTAINER Jon Jagger <jon@jaggersoft.com>

WORKDIR /app/

COPY prepare_platform.sh /app/
RUN [ "./prepare_platform.sh" ]

COPY Gemfile        /app/
COPY prepare_app.sh /app/
COPY Procfile       /app/
COPY config.ru      /app/
COPY src/       /app/src/
COPY test/      /app/test/
RUN [ "./prepare_app.sh" ]

EXPOSE 4567
CMD [ "foreman", "start", "-d", "/app" ]
