FROM cyberdojo/sinatra
MAINTAINER Jon Jagger <jon@jaggersoft.com>

COPY Procfile  /app/
COPY config.ru /app/
COPY app.rb    /app/

EXPOSE 4568
CMD [ "foreman", "start", "-d", "/app" ]
