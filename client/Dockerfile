FROM cyberdojo/rack-base:8fb133a
LABEL maintainer=jon@jaggersoft.com

WORKDIR /differ
COPY --chown=nobody:nogroup . .

ARG COMMIT_SHA
ARG CYBER_DOJO_DIFFER_CLIENT_PORT

ENV SHA=${COMMIT_SHA}
ENV PORT=${CYBER_DOJO_DIFFER_CLIENT_PORT}

EXPOSE ${PORT}
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/heathcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/differ/config/up.sh" ]
