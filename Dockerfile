FROM restic/restic:0.18.1

RUN apk add --no-cache tzdata tini supercronic

ENTRYPOINT ["/sbin/tini", "--"]
