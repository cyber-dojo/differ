FROM cyberdojo/differ_base
MAINTAINER Jon Jagger <jon@jaggersoft.com>

ARG app_dir

COPY Procfile       ${app_dir}/
COPY config.ru      ${app_dir}/
COPY src/           ${app_dir}/src/
COPY test/          ${app_dir}/test/

EXPOSE 4567
