FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

# - - - - - - - - - - - - - - - - -
# setup client
# - - - - - - - - - - - - - - - - -

ARG                            DIFFER_HOME=/app
COPY .                       ${DIFFER_HOME}
RUN  chown -R nobody:nogroup ${DIFFER_HOME}
USER nobody

EXPOSE 4568
CMD [ "./up.sh" ]
