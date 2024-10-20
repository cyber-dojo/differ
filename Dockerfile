FROM cyberdojo/sinatra-base:f20e0b5
LABEL maintainer=jon@jaggersoft.com

RUN apk --update --upgrade --no-cache add git

WORKDIR /differ
COPY --chown=nobody:nogroup app/server .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG CYBER_DOJO_DIFFER_PORT
ENV CYBER_DOJO_DIFFER_PORT=${CYBER_DOJO_DIFFER_PORT}

USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT [ "/sbin/tini", "-g", "--" ]
CMD [ "/differ/config/up.sh" ]
