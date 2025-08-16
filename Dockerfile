FROM ghcr.io/cyber-dojo/sinatra-base:b757853@sha256:e08a1a8f707ddb56f2c84b1f7eaaa5ca33e5d64bc1e53f2fd7412fa264b3ac0c
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

RUN apk --update --upgrade --no-cache add git

WORKDIR /differ
COPY source/server .
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT [ "/sbin/tini", "-g", "--" ]
CMD [ "/differ/config/up.sh" ]
