FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY --chown=nobody:nogroup . .

ARG CYBER_DOJO_DIFFER_CLIENT_PORT
ENV PORT=${CYBER_DOJO_DIFFER_CLIENT_PORT}
EXPOSE ${PORT}

USER nobody
CMD [ "/app/up.sh" ]
