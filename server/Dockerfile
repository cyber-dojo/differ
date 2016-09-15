FROM cyberdojo/sinatra
MAINTAINER Jon Jagger <jon@jaggersoft.com>

# server/test/src/run.sh needs bash
RUN apk add --update git bash

COPY Procfile  /usr/app/
COPY config.ru /usr/app/
COPY src/      /usr/app/src/
COPY test/     /usr/app/test/

EXPOSE 4567
CMD [ "foreman", "start", "-d", "/usr/app" ]
