# Resticronic

Docker image containing restic and supercronic.

## Overview

Resticronic is a Docker image that combines [restic](https://restic.net/), a fast, secure, and efficient backup program, with [supercronic](https://github.com/aptible/supercronic), a cron replacement for running jobs in containers. This image allows you to easily schedule and run backup tasks using restic within a Docker container.

## Pulling the Image

To get started, pull the Resticronic image from GitHub Container Registry:

```shell
docker pull ghcr.io/querateam/resticronic
```

### Tags and Versioning

Resticronic images are tagged according to the restic version they include. This allows you to pin to a specific restic version if needed. For example, to use restic version `0.18.1`, you can pull the image with the corresponding tag:

```shell
docker pull ghcr.io/querateam/resticronic:0.18.1
```

You can find the available tags on the [GitHub Container Registry page](https://github.com/querateam/resticronic/pkgs/container/resticronic).


## Usage

### Running Restic

You can directly run the `restic` binary:

```bash
docker run --rm ghcr.io/querateam/resticronic restic version
```

### Using Supercronic

To use supercronic, create a `crontab` file like this:

```shell
# crontab
*/1 * * * * restic version
```

Mount the crontab file and run the container:

```shell
docker run --rm -v ./crontab:/crontab \
  ghcr.io/querateam/resticronic \
  supercronic /crontab
```

To define the cron jobs in a specific timezone, you can set the `TZ` environment variable (e.g., `Asia/Tehran`). For more details on timezone configuration, refer to the [Supercronic documentation](https://github.com/aptible/supercronic?tab=readme-ov-file#timezone).

### Using `RESTICRONIC_CRONTAB`

You can skip mounting a crontab file by providing your cron entries via the `RESTICRONIC_CRONTAB` environment variable.

```bash
docker run --rm \
  -e RESTICRONIC_CRONTAB='*/1 * * * * restic version' \
  ghcr.io/querateam/resticronic
```

When this variable is set, the container will write its contents to `/etc/resticronic/crontab`. If you don't pass a command, the entrypoint will automatically run `supercronic /etc/resticronic/crontab`.

If you'd like to pass additional flags to supercronic (for example, `-passthrough-logs`), you can still provide an explicit command while using `RESTICRONIC_CRONTAB`:

```bash
docker run --rm \
  -e RESTICRONIC_CRONTAB='*/1 * * * * restic version' \
  ghcr.io/querateam/resticronic \
  supercronic -passthrough-logs /etc/resticronic/crontab
```

## Example: Scheduled Backup

This example schedules a backup of the `/data` directory every day at 2 AM.

```bash
docker run --rm \
  -v /path/to/data:/data \
  -v /path/to/restic-repo:/repo \
  -v /path/to/restic-cache:/var/cache/restic \
  -e TZ=Asia/Tehran \
  -e RESTIC_PASSWORD=password \
  -e RESTIC_CACHE_DIR=/var/cache/restic \
  -e RESTICRONIC_CRONTAB='0 2 * * * restic --repo /repo backup /data' \
  ghcr.io/querateam/resticronic
```

A docker compose example:

```yaml
services:
  backup:
    image: ghcr.io/querateam/resticronic
    restart: always
    # You can optionally run as a non-root user:
    user: 1000:1000
    secrets:
      - restic_password
    volumes:
      - restic-cache:/var/cache/restic
      - /path/to/data:/data:ro
      - /path/to/repo:/repo
    environment:
      # Timezone for crontab:
      TZ: ${TZ:-Asia/Tehran}
      # Restic needs a unique and fixed hostname to identify the snapshots.
      # https://forum.restic.net/t/restic-never-finds-a-parent-snapshot-when-the-snapshot-exists/4312/2
      RESTIC_HOST: my-unique-hostname
      RESTIC_CACHE_DIR: /var/cache/restic
      RESTIC_READ_CONCURRENCY: 2
      RESTIC_PASSWORD_FILE: /run/secrets/restic_password
      RESTICRONIC_CRONTAB: |
        # Daily backup at 02:00
        0 2 * * * restic --repo /repo backup /data

volumes:
  restic-cache:

secrets:
  restic_password:
    file: ./secrets/restic_password
```

You can use all environment variables supported by `restic`. Some commonly used ones include:

- `RESTIC_REPOSITORY`: The location of the restic repository.
- `RESTIC_PASSWORD`: The password for the restic repository.
- `RESTIC_PASSWORD_FILE`: Path to a file containing the password for the restic repository.
- `RESTIC_CACHE_DIR`: Directory to store the restic cache.
- `RESTIC_HOST`: A unique hostname to identify snapshots.

## Acknowledgements

- [restic](https://github.com/restic/restic)
- [supercronic](https://github.com/aptible/supercronic)
