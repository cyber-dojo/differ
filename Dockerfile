FROM ghcr.io/cyber-dojo/sinatra-base:6d1262a@sha256:2282f8f00e03aeaf93e6ae5753c57986b3e6458325e354139b6315b239e81791 AS base
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV COMMIT_SHA=${COMMIT_SHA}

ARG APP_DIR=/differ 
ENV APP_DIR=${APP_DIR}

RUN apk --update --upgrade --no-cache add git

WORKDIR ${APP_DIR}/source
COPY source/server .
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT [ "/sbin/tini", "-g", "--" ]
CMD [ "./config/up.sh" ]
