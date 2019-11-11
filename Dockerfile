FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN apk --update --upgrade --no-cache add git

WORKDIR /app
COPY --chown=nobody:nogroup . .

ARG SHA
ENV SHA=${SHA}

EXPOSE 4567

USER nobody
CMD [ "./up.sh" ]
