ARG BASE_IMAGE=cyberdojo/sinatra-base:f20e0b5
FROM ${BASE_IMAGE}
LABEL maintainer=jon@jaggersoft.com

WORKDIR /differ
COPY --chown=nobody:nogroup . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/differ/config/up.sh" ]
