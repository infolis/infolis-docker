infolis-docker
--------------
Run the InFoLiS infrastructure as docker containers.

<!-- BEGIN-MARKDOWN-TOC -->
* [Overview](#overview)
* [Prerequisites](#prerequisites)
	* [Hardware](#hardware)
	* [Software](#software)
* [Build](#build)
	* [Clone repos recursively](#clone-repos-recursively)
	* [Create directory structure](#create-directory-structure)
	* [Build/Pull container images](#build-pull-container-images)
* [Configure](#configure)
	* [Network setup](#network-setup)
	* [Data directories](#data-directories)
	* [infolis-github](#infolis-github)
* [Start and stop](#start-and-stop)
* [Utilities](#utilities)
	* [`make backup`](#make-backup)
	* [`make restore`](#make-restore)
	* [`make clear`](#make-clear)

<!-- END-MARKDOWN-TOC -->

## Overview

The [InFoLiS project](http://infolis.github.io) tries to facilitate a
tighter integration of academic publications and research data by
using text mining techniques to extract references to data from
natural language texts.

The different parts of the project have been implemented with
different technologies in different repositories. `infolis-docker` is
the umbrella repository that "wires together" all the components and
makes them easy to deploy.

## Prerequisites

### Hardware

Database, web frontend and web site are modest in their requirements,
the [data mining backend](/infolis/infolink) however can be
quite resource hungry.

If you intend to deploy all the containers on the same host, we'd
recommend at least 16 GB of RAM and 2 CPU cores.

If you run the backend on a different (powerful) machine, 4 GB of RAM
and 2 CPU cores should be enough to run the frontend.

### Software

The software is deployed using the docker container framework. While
technically possible to run in Windows, Linux and Mac OSX, we do not
support operating systems beyond Linux.

* docker-engine
* docker-compose
* GNU make

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

### Network setup

If the host of the `infolis-web`/`infolis-github` containers is running on a
non-DNS-resolvable host (e.g. `localhost:3000`), ensure that
they are resolvable locally by adding to `/etc/hosts`:

```
127.0.0.1	infolis-web
127.0.0.1	infolis-github
```

### Data directories

All data is stored in the `./data` directory:

* `./data/logs`: Logs from infolis-web
* `./data/mongodb`: The MongoDB backend of infolis-web
* `./data/uploads`: The file uploads to infoLink

Backups (see [`make-backup`](#make-backup) and
[`make-restore`](#make-restore)) are stored in `./backup`


### infolis-github

You won't need to run this container unless you are developing the
[InFoLiS web site](/infolis/infolis.github.io).

## Start and stop

* `docker-compose up [SERVICE...]` to start the containers and follow the logs.  `<CTRL-C>` to quit.
* `docker-compose up -d [SERVICE...]` to start the containers and detach.
* `docker-compose stop [SERVICE...]` to stop the containers.

`[SERVICE...]` should be `infolis-web infolink` in general.

If you want to run the web site from docker as well, `[SERVICE...]`
should be `infolis-web infolink infolis-github`.

## Utilities

`infolis-docker` comes with a [`Makefile`](./Makefile) that offers
some utility targets.

### `make backup`

`make backup` will create a time-stamped directory in `./backup` with
a snapshot of the Mongo DB (using `mongodump`) and a copy of the
uploaded files.

### `make restore`

`make restore BACKUP=<timestamp>` will restore MongoDB documents and
uploads from the backup `./backup/<timestamp>`.

### `make clear`

`make clear` will drop the database and remove all files. Use with
caution, obviously.
