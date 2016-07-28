FROM alpine:3.2
MAINTAINER Jon Jagger <jon@jaggersoft.com>
# See https://blog.codeship.com/build-minimal-docker-container-ruby-apps/

ENV BUILD_PACKAGES bash curl-dev ruby-dev build-base
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler

# Update and install all of the required packages.
# At the end, remove the apk cache
RUN apk update && \
    apk upgrade && \
    apk add $BUILD_PACKAGES && \
    apk add $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

RUN mkdir /usr/app
WORKDIR /usr/app

COPY Gemfile /usr/app/
RUN bundle install

COPY Procfile /usr/app/
COPY config.ru /usr/app/
COPY app.rb /usr/app/

EXPOSE 4567
CMD ["foreman","start","-d","/usr/app"]
