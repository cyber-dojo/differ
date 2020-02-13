FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN apk --update --upgrade --no-cache add git

COPY --chown=nobody:nogroup . /app

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG CYBER_DOJO_DIFFER_PORT
ENV PORT=${CYBER_DOJO_DIFFER_PORT}
EXPOSE ${PORT}

USER nobody
CMD [ "/app/up.sh" ]
