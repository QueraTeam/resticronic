FROM restic/restic:0.18.0

RUN apk add --no-cache tzdata tini supercronic

ENTRYPOINT ["/sbin/tini", "--"]
