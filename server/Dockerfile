FROM cyberdojo/sinatra
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# server/test/src/run.sh needs bash
RUN apk add --update git bash

COPY Procfile  /app/
COPY config.ru /app/
COPY src/      /app/src/
COPY test/     /app/test/

EXPOSE 4567
CMD [ "foreman", "start", "-d", "/app" ]
