infolis-docker
--------------
Run the InFoLiS infrastructure as docker containers.

<!-- BEGIN-MARKDOWN-TOC -->
* [Prerequisites](#prerequisites)
	* [Hardware](#hardware)
	* [Software](#software)
* [Clone](#clone)
* [Create directory structure](#create-directory-structure)
* [Build/Pull container images](#build-pull-container-images)
* [Configure](#configure)
* [Run](#run)
* [Creating backups](#creating-backups)

<!-- END-MARKDOWN-TOC -->

## Prerequisites

### Hardware

* 16 GB RAM
* 4 Cores

### Software

* docker-engine
* docker-compose

## Build

### Clone repos recursively

```
git clone --recursive https://github.com/infolis/infolis-docker
```

### Create directory structure

`make dirs` or

```
mkdir -p data/{logs,mongodb,uploads} backup
```

### Build/Pull container images

`make build` or

```
docker-compose build
docker-compose pull mongo
```

## Configure

Adapt the files in [`./config`](./config) to your needs.

If the host of the `infolis-web`/`infolis-github` containers is running on a
non-DNS-resolvable host (e.g. `localhost:3000`), ensure that
they are resolvable locally by adding to `/etc/hosts`:

```
127.0.0.1	infolis-web
127.0.0.1	infolis-github
```

## Run

`docker-compose up` to start the containers and follow the logs.  `<CTRL-C>` to quit.

`docker-compose start` to start the containers in the background.  `docker-compose stop` to quit.

## Creating backups

`make backup` will create a time-stamped directory in `./backup` with
a snapshot of the Mongo DB (using `mongodump`) and a copy of the
uploaded files. Use this to restore a previous state.
