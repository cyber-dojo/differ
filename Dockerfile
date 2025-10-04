FROM ghcr.io/cyber-dojo/sinatra-base:da81cef@sha256:766cd5cc61bc5655244da0433a9e1d95354e7fa24eae51a96544f794737c42e0
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
