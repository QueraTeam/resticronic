FROM restic/restic:0.17.3

RUN apk add --no-cache tzdata tini supercronic

ENTRYPOINT ["/sbin/tini", "--"]
