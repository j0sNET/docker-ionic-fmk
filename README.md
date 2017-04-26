![Ionic](http://ionicframework.com/img/ionic-logo.png)

[![Docker Hub](https://img.shields.io/badge/Docker-josnet%2Fionic__fwk-blue.svg)](https://registry.hub.docker.com/u/josnet/ionic-fmk/)

This repository contains the **Dockerfile** which is ready-to-go hybrid development environment for building amazing mobile apps with [Ionic framework](http://ionicframework.com) on [Docker](https://www.docker.com/).

* Based on official [docker node image](https://hub.docker.com/_/node/)

This image is using the following tools:

* Android SDK Tools, revision 25.2.5
* Android SDK Build Tools, revision 19.1.0, 22.0.1, 23.0.3
* Android SDK Platform, x86 API level 15, 19, 22


Requirements
---------------------
[![docker](https://www.docker.com/sites/default/files/dockertwo_0.png){:height="199px" width="430px"}](https://www.docker.com/)


How to use it?
---------------
### Installation

* Build image from a Dockerfile

    `$ docker build -t josnet/ionic_fwk:latest .`


* Download image from Docker Hub

    `$ docker pull josnet/ionic_fwk`

Usage
-----

#### Run demo

```
$ docker run -it --rm --name ionic-demo \
  -p 8100:8100 -p 35729:35729 josnet/ionic_fwk
```

#### Run your own ionic resources

```bash
$ cd <project_path>/
$ docker run -it --rm --name ionic-deploy \
  -p 8100:8100 -p 35729:35729 \
  -v $(pwd):/workspace/app:ro josnet/ionic_fwk
```

Creating a project
------------------

You can follow the [Ionic tutorial](http://ionicframework.com/getting-started/) (except for the ios part...) without having to install ionic nor cordova nor nodejs on your computer.

Start building high-quality mobile apps:

##### Manual

```bash
$ cd <workspace_path>/
$ docker run -it --name ionic-dev -h ionic-dev \
    -p 8100:8100 -p 35729:35729 \
    -v $(pwd):/projects/ionic:rw josnet/ionic_fwk /bin/bash

$ ionic start mySuperApp blank --v2 --ts
$ cd mySuperApp
$ ionic serve --all \
    --port 8100 \
    --livereload-port 35729 \
    -l -c
```

##### Automation

_Coming next_


PREVIEWING THE APP
------------------

To see what our demo app looks like, open [demo-ionic](http://192.168.99.100:8100/).

> In case it didn't work out, replace the ip address with the following output from:
> `$ docker-machine ip default`