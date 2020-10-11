FROM cyberdojo/rack-base:dfe5945
LABEL maintainer=jon@jaggersoft.com

WORKDIR /differ
COPY --chown=nobody:nogroup . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG CYBER_DOJO_DIFFER_CLIENT_PORT
ENV PORT=${CYBER_DOJO_DIFFER_CLIENT_PORT}
EXPOSE ${PORT}

USER nobody
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/differ/config/up.sh" ]
