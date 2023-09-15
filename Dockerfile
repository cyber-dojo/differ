FROM cyberdojo/sinatra-base:396f3d2
LABEL maintainer=jon@jaggersoft.com

RUN apk --update --upgrade --no-cache add git

WORKDIR /differ
COPY --chown=nobody:nogroup . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT [ "/sbin/tini", "-g", "--" ]
CMD [ "/differ/config/up.sh" ]
