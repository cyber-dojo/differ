FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

ARG                            DIFFER_HOME=/app
COPY .                       ${DIFFER_HOME}
RUN  chown -R nobody:nogroup ${DIFFER_HOME}
USER nobody

ARG SHA
RUN echo ${SHA} > ${DIFFER_HOME}/sha.txt

EXPOSE 4567
CMD [ "./up.sh" ]