FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN apk --update --upgrade --no-cache add git

COPY --chown=nobody:nogroup . /app

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

EXPOSE 4567

USER nobody
CMD [ "/app/up.sh" ]
