FROM cyberdojo/sinatra-base:759c4e9@sha256:d5f87f343a9f88a598b810c0f02b81db0bb67319701a956aec3577cbd51c1c24
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

WORKDIR /differ
COPY . .
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/differ/config/up.sh" ]
