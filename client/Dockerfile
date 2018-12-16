FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

ARG                            DIFFER_HOME=/app
COPY .                       ${DIFFER_HOME}
RUN  chown -R nobody:nogroup ${DIFFER_HOME}

EXPOSE 4568
USER nobody
CMD [ "./up.sh" ]
