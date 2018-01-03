FROM  alpine:latest
LABEL maintainer=jon@jaggersoft.com

# - - - - - - - - - - - - - - - - -
# install ruby+
# tar is needed to tar-pipe test coverage out of tmpfs.
# - - - - - - - - - - - - - - - - -

RUN apk --update --no-cache add \
    bash \
    git \
    ruby-bundler \
    ruby-dev \
    tar

# - - - - - - - - - - - - - - - - -
# install ruby gems
# - - - - - - - - - - - - - - - - -

ARG             CYBER_DOJO_DIFFER_HOME
COPY Gemfile  ${CYBER_DOJO_DIFFER_HOME}/
WORKDIR       ${CYBER_DOJO_DIFFER_HOME}

RUN apk --update add --virtual build-dependencies build-base \
  && bundle config --global silence_root_warning 1 \
  && bundle install \
  && gem clean \
  && apk del build-dependencies build-base \
  && rm -vrf /var/cache/apk/*

# - - - - - - - - - - - - - - - - -
# setup client
# - - - - - - - - - - - - - - - - -

COPY . ${CYBER_DOJO_DIFFER_HOME}
RUN  chown -R nobody:nogroup ${CYBER_DOJO_DIFFER_HOME}
USER nobody

ARG PORT
EXPOSE ${PORT}
ENV PORT=${PORT}

CMD [ "./up.sh" ]
