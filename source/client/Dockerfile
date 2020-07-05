FROM cyberdojo/rack-base:2e387b6
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY --chown=nobody:nogroup . .

ARG CYBER_DOJO_DIFFER_CLIENT_PORT
ENV PORT=${CYBER_DOJO_DIFFER_CLIENT_PORT}
EXPOSE ${PORT}

USER nobody
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/app/up.sh" ]
