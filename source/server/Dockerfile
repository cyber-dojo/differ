FROM cyberdojo/rack-base:2e387b6
LABEL maintainer=jon@jaggersoft.com

RUN apk --update --upgrade --no-cache add git

COPY --chown=nobody:nogroup . /app

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG CYBER_DOJO_DIFFER_PORT
ENV PORT=${CYBER_DOJO_DIFFER_PORT}
EXPOSE ${PORT}

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/app/up.sh" ]
