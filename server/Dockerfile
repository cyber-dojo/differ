FROM alpine:edge
MAINTAINER Jon Jagger <jon@jaggersoft.com>

ARG app_dir

WORKDIR ${app_dir}/

COPY prepare_platform.sh ${app_dir}/
RUN [ "./prepare_platform.sh" ]

COPY Gemfile        ${app_dir}/
COPY prepare_app.sh ${app_dir}/
RUN [ "./prepare_app.sh" ]

COPY Procfile       ${app_dir}/
COPY config.ru      ${app_dir}/
COPY src/           ${app_dir}/src/
COPY test/          ${app_dir}/test/

EXPOSE 4567
