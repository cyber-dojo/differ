FROM cyberdojo/foreman
MAINTAINER Jon Jagger <jon@jaggersoft.com>

RUN export RACK_ENV='production'

ARG PORT
ENV PORT=${PORT}
EXPOSE ${PORT}

CMD [ "foreman", "start", "-d", "/app" ]

WORKDIR /app
COPY . /app
