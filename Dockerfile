FROM cyberdojo/rack-base:dfe5945
LABEL maintainer=jon@jaggersoft.com

RUN apk --update --upgrade --no-cache add git

WORKDIR /differ
COPY --chown=nobody:nogroup . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

ARG CYBER_DOJO_DIFFER_PORT
ENV PORT=${CYBER_DOJO_DIFFER_PORT}
EXPOSE ${PORT}

# --interval=S     time until 1st healthcheck
# --timeout=S      fail if single healthcheck takes longer than this
# --retries=N      number of tries until container considered unhealthy
# --start-period=S grace period when healthcheck fails dont count towards --retries

HEALTHCHECK         \
  --interval=1s     \
  --timeout=1s      \
  --retries=5       \
  --start-period=5s \
  CMD ./config/heathcheck.sh

USER nobody
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/differ/config/up.sh" ]
