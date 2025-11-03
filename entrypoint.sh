#!/bin/sh

if [ -n "${RESTICRONIC_CRONTAB}" ]; then
    echo "${RESTICRONIC_CRONTAB}" >/etc/resticronic/crontab
    echo "Created /etc/resticronic/crontab from RESTICRONIC_CRONTAB environment variable."
    if [ -z "$@" ]; then
        set -- supercronic /etc/resticronic/crontab
    fi
fi

exec "$@"
