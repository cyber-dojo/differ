FROM cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN apk --update --upgrade --no-cache add git
WORKDIR /app
COPY . .
RUN chown -R nobody:nogroup .

ARG SHA
ENV SHA=${SHA}

EXPOSE 4567
USER nobody
# root user is needed for the [chmod 1777 /tmp]
# inside up.sh :-( Would like to get back to USER nobody
#USER root

CMD [ "./up.sh" ]
