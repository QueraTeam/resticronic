FROM restic/restic:0.18.1

RUN apk add --no-cache tzdata tini supercronic

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create a world-writable directory to enable this image to be run by any non-root user.
RUN mkdir -p /etc/resticronic && chmod 0777 /etc/resticronic

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
