FROM alpine:edge
MAINTAINER Jon Jagger <jon@jaggersoft.com>

ARG app_dir

WORKDIR ${app_dir}/

COPY Gemfile        ${app_dir}/
COPY prepare.sh     ${app_dir}/
RUN [ "./prepare.sh" ]
