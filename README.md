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
    0 2 * * * restic -r /repo backup /data
    ```

    This example schedules a backup of the `/data` directory every day at 2 AM.

2. Run the container with the crontab file:

    ```shell
    docker run --rm -e TZ=Asia/Tehran \
      -v /path/to/backup-crontab:/crontab \
      -v /path/to/data:/data \
      -v /path/to/restic-repo:/repo \
      -e RESTIC_PASSWORD=password \
      ghcr.io/querateam/resticronic \
      supercronic /crontab
    ```

## Environment Variables

- `TZ`: Set the timezone for the cron jobs.
- `RESTIC_PASSWORD`: Password for the restic repository.

## Acknowledgements

- [restic](https://restic.net/)
- [supercronic](https://github.com/aptible/supercronic)
