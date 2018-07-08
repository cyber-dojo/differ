ARG   ALPINE_VERSION
FROM  alpine:${ALPINE_VERSION}
LABEL maintainer=jon@jaggersoft.com

# - - - - - - - - - - - - - - - - -
# install ruby+
# tar is needed to tar-pipe test coverage out of tmpfs.
# - - - - - - - - - - - - - - - - -

RUN apk --update --no-cache add \
    bash \
    ruby-bundler \
    ruby-dev \
    tar

# - - - - - - - - - - - - - - - - -
# install ruby gems
# - - - - - - - - - - - - - - - - -

ARG             DIFFER_HOME
COPY Gemfile  ${DIFFER_HOME}/
WORKDIR       ${DIFFER_HOME}

RUN apk --update add --virtual build-dependencies build-base \
  && bundle config --global silence_root_warning 1 \
  && bundle install \
  && gem clean \
  && apk del build-dependencies build-base \
  && rm -vrf /var/cache/apk/*

# - - - - - - - - - - - - - -
# install non-commons
# - - - - - - - - - - - - - -

RUN apk --update --no-cache add \
    git

# - - - - - - - - - - - - - - - - -
# setup client
# - - - - - - - - - - - - - - - - -

COPY . ${DIFFER_HOME}
RUN  chown -R nobody:nogroup ${DIFFER_HOME}
USER nobody

CMD [ "./up.sh" ]
