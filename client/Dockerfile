FROM cyberdojo/sinatra
MAINTAINER Jon Jagger <jon@jaggersoft.com>

COPY Procfile  /usr/app/
COPY config.ru /usr/app/
COPY app.rb    /usr/app/

EXPOSE 4568
CMD [ "foreman", "start", "-d", "/usr/app" ]
