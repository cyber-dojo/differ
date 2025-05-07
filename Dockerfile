FROM cyberdojo/sinatra-base:84a340c@sha256:cc7a4f3f8d7641b5961691d4c7b6e513e799d154bcdaa244442cda2e0419906f
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

RUN apk --update --upgrade --no-cache add git

WORKDIR /differ
COPY source/server .
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT [ "/sbin/tini", "-g", "--" ]
CMD [ "/differ/config/up.sh" ]
