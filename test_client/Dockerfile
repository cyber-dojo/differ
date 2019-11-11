FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY --chown=nobody:nogroup . .

EXPOSE 4568

USER nobody
CMD [ "./up.sh" ]
