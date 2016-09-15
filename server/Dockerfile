FROM alpine:edge
MAINTAINER Jon Jagger <jon@jaggersoft.com>

ARG app_dir

WORKDIR ${app_dir}/

COPY Gemfile        ${app_dir}/
COPY prepare.sh     ${app_dir}/
RUN [ "./prepare.sh" ]

COPY Procfile       ${app_dir}/
COPY config.ru      ${app_dir}/
COPY src/           ${app_dir}/src/
COPY test/          ${app_dir}/test/

EXPOSE 4567
