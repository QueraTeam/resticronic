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

Resticronic images are tagged according to the restic version they include. This allows you to pin to a specific restic version if needed. For example, to use restic version `0.17.3`, you can pull the image with the corresponding tag:

```shell
docker pull ghcr.io/querateam/resticronic:0.17.3
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

### Example: Scheduled Backup

1. Create a crontab file `backup-crontab` with the following content:

    ```shell
    # backup-crontab
    0 2 * * * restic --repo /repo backup /data
    ```

    This example schedules a backup of the `/data` directory every day at 2 AM.

2. Run the container with the crontab file:

    ```shell
    docker run --rm \
      -v /path/to/backup-crontab:/crontab \
      -v /path/to/data:/data \
      -v /path/to/restic-repo:/repo \
      -v /path/to/restic-cache:/var/cache/restic \
      -e TZ=Asia/Tehran \
      -e RESTIC_PASSWORD=password \
      -e RESTIC_CACHE_DIR=/var/cache/restic \
      ghcr.io/querateam/resticronic \
      supercronic /crontab
    ```

A docker compose example:

```yaml
services:
  backup:
    image: ghcr.io/querateam/resticronic
    command: supercronic -passthrough-logs /crontab
    restart: always
    secrets:
      - restic_password
    volumes:
      - restic-cache:/var/cache/restic
      - /path/to/crontab:/crontab:ro
      - /path/to/data:/data:ro
      - /path/to/repo:/repo
    environment:
      # Timezone for crontab
      TZ: ${TZ:-Asia/Tehran}
      # Restic needs a unique and fixed hostname to identify the snapshots.
      # https://forum.restic.net/t/restic-never-finds-a-parent-snapshot-when-the-snapshot-exists/4312/2
      RESTIC_HOST: my-unique-hostname
      RESTIC_CACHE_DIR: /var/cache/restic
      RESTIC_READ_CONCURRENCY: 2
      RESTIC_PASSWORD_FILE: /run/secrets/restic_password

volumes:
  restic-cache:

secrets:
  restic_password:
    file: ./secrets/restic_password
```

## Environment Variables

You can use all environment variables supported by `restic`. Some commonly used ones include:

- `RESTIC_REPOSITORY`: The location of the restic repository.
- `RESTIC_PASSWORD`: The password for the restic repository.
- `RESTIC_PASSWORD_FILE`: Path to a file containing the password for the restic repository.
- `RESTIC_CACHE_DIR`: Directory to store the restic cache.
- `RESTIC_HOST`: A unique hostname to identify snapshots.

To define the cron jobs in a specific timezone, you can set the `TZ` environment variable (e.g., `Asia/Tehran`). For more details on timezone configuration, refer to the [Supercronic documentation](https://github.com/aptible/supercronic?tab=readme-ov-file#timezone).

## Acknowledgements

- [restic](https://github.com/restic/restic)
- [supercronic](https://github.com/aptible/supercronic)
