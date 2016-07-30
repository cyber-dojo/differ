FROM cyberdojo/sinatra
MAINTAINER Jon Jagger <jon@jaggersoft.com>

COPY Procfile  /usr/app/
COPY config.ru /usr/app/
COPY *.rb      /usr/app/

EXPOSE 4567
CMD [ "foreman", "start", "-d", "/usr/app" ]
