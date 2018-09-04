FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

# - - - - - - - - - - - - - - - - -
# setup server
# - - - - - - - - - - - - - - - - -

ARG                            DIFFER_HOME=/app
COPY .                       ${DIFFER_HOME}
RUN  chown -R nobody:nogroup ${DIFFER_HOME}
USER nobody

# - - - - - - - - - - - - - - - - -
# git commit sha image is built from
# - - - - - - - - - - - - - - - - -

ARG SHA
RUN echo ${SHA} > ${DIFFER_HOME}/sha.txt

# - - - - - - - - - - - - - - - - -
# bring it up
# - - - - - - - - - - - - - - - - -

EXPOSE 4567
CMD [ "./up.sh" ]
