FROM cyberdojo/sinatra
MAINTAINER Jon Jagger <jon@jaggersoft.com>

RUN apk add --update git

COPY Procfile  /usr/app/
COPY config.ru /usr/app/
COPY *.rb      /usr/app/
COPY lib/*.rb  /usr/app/lib/

EXPOSE 4567
CMD [ "foreman", "start", "-d", "/usr/app" ]
