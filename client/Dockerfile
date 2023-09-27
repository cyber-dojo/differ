FROM cyberdojo/rack-base:be46d16
LABEL maintainer=jon@jaggersoft.com

WORKDIR /differ
COPY --chown=nobody:nogroup . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/differ/config/up.sh" ]
