FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

ARG HOME=/app
ARG SHA

COPY . ${HOME}
RUN echo ${SHA} > ${HOME}/sha.txt
RUN chown -R nobody:nogroup ${HOME}

EXPOSE 4567
USER nobody
CMD [ "./up.sh" ]
