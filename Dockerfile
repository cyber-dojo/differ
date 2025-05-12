FROM cyberdojo/sinatra-base:2bd775a@sha256:8c345664508f09f9b6d7b9b2c08470e1a4747fff697a12807f86bf596f1d3d15
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
