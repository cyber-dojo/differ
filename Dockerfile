FROM ghcr.io/cyber-dojo/sinatra-base:4d448af@sha256:d2d3fd0451afc5954ea4433e41f6f17ad6ad856bf607c9cd23dd4cf9c32b6ce8 AS base
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

# The workflow caches the bare image (this base stage) by a hash of this
# stage's instructions (comments and blank lines aside), so these unpinned
# packages are as new as the last change to those instructions. To pick up
# newer ones, eg a git security fix, bump APK_REFRESH.
ARG APK_REFRESH=1
RUN apk --update --upgrade --no-cache add git

# path_coverage measures which paths through each decision and method the
# tests take, alongside SimpleCov's line and branch coverage. It is used only
# by the server test suite (test/server/lib/coverage.rb). It is pinned to
# keep the image reproducible.
RUN gem install --no-document path_coverage --version 0.7.2

ARG APP_DIR=/differ
ENV APP_DIR=${APP_DIR}

# Created as root, before USER, so the nobody user cannot add, remove or
# rename files in the source dir.
WORKDIR ${APP_DIR}/source
USER nobody

# The stage above, base, is the bare image: Ruby, its gems, the OS packages
# and the nobody user it runs as, with no source code. The stage below adds
# the source code, making the deployed image. Built with --target base it is
# the bare image the server tests run in (bin/run_tests_bare.sh); built with
# --build-context base=<that bare image>, the deployed image is built FROM
# the very bare image the tests ran in (.github/workflows/main.yml).
FROM base

ARG COMMIT_SHA
ENV COMMIT_SHA=${COMMIT_SHA}

# Owned by root, so the nobody user it runs as cannot change its own code.
COPY --chown=root:root source/server .
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT [ "/sbin/tini", "-g", "--" ]
CMD [ "./config/up.sh" ]
