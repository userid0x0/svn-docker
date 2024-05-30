[![Docker Image](https://img.shields.io/badge/Docker%20Image-available-success&style=flat)](https://hub.docker.com/r/userid0x0/svn-docker/)
[![Build](https://img.shields.io/github/actions/workflow/status/userid0x0/svn-docker/docker-build.yml?branch=master&label=build&logo=github&style=flat)](https://github.com/userid0x0/svn-docker/actions)

It's a fork of https://github.com/elleFlorio/svn-docker & https://github.com/sea-kg/svn-docker

# Description
Lightweight container providing an SVN server, based on **Alpine Linux** and S6 process management (see [here](https://github.com/crazy-max/docker-alpine-s6) for details).
The access to the server is possible via **WebDav protocol** (http://).

Components (Tag `v3.20`):
- Alpine Linux (3.20) with S6 Overlay (3.1.5.0)
- svn + apache taken from Alpine Linux
- iF.SVNAdmin web-interface used from [https://github.com/mfreiholz/iF.SVNAdmin](https://github.com/mfreiholz/iF.SVNAdmin)
<br>version: 1.6.2 + some patches for PHP8.2
- WebSVN web-interface used from [https://github.com/websvnphp/websvn](https://github.com/websvnphp/websvn)<br>version: 2.8.4
- Repos-Style XSLT Stylesheet used from [https://github.com/rburgoyne/repos-style](https://github.com/rburgoyne/repos-style)

## Tags
- `latest` latest version
- `v3.20` based on Alpine Linux 3.20
- `v3.19` based on Alpine Linux 3.19
- `v3.18` based on Alpine Linux 3.18
- `v3.17` based on Alpine Linux 3.17
# How to run
To run the image, you can use the following command:
```bash
$ docker run \
    --name svn-server \
    -p 8080:80 \
    -e SVN_SERVER_REPOSITORIES_URL=/svn \
    -e WEBSVN_URL=/websvn \
    -e WEBSVN_AUTH=2 \
    -e SVN_SERVER_REPOS_STYLE_AUTH=2 \
    -v `pwd`/data:/data \
    docker.io/userid0x0/svn-docker
```

## Environment variables
- `SVN_SERVER_REPOSITORIES_URL` location of the SVN repo on the web interface<br>default: `/svn`
- `SVN_SERVER_REPOS_STYLE_AUTH` authentification used for Repos-Style history functionality<br>default: `2`
    - `0` no authentification used (public access)
    - `1` read access for all known users for all repositories
    - `2` read access to all known users repecting `svnauthz`<br>disables history functionality (security leak)
- `WEBSVN_URL` location of the WebSVN web interface<br>default: `/websvn`<br>websvn will be disabled when the URL is empty
- `WEBSVN_AUTH` authentification used for WebSVN<br>default: `2`
    - `0` no authentification used (public access)
    - `1` read access for all known users for all repositories
    - `2` read access to all known users repecting `svnauthz` (e.g. controlled via iF.SVNAdmin)
## Volume `/data`
- `<data>/repositories` - will be keep all repositories in subfolder in data
- `<data>/subversion` - configurations for subversion (passwd && subversion-access-control)
- `<data>/svnadmin` - svnadmin related
- `<data>/websvn` - websvn related

## Building
``` bash
$ docker build --tag localhost/svn-docker .
```

## URLs
- http://localhost:8080/svnadmin - configuration
- http://localhost:8080/svn - with repositories
- http://localhost:8080/websvn - websvn access

# First start
Create a local `data` folder for persistent storage and start `svn-docker` e.g.
```bash
$ cd <mydir>
$ mkdir data
$ docker run --name svn-server -p 8080:80 -v `pwd`/data:/data docker.io/userid0x0/svn-docker
```
With the first start `/data` will be inited automatically - folders/files/password - for easy start.

Defaults:
- `read-only` permissions for all known users
- login: `admin` / password: `admin` **Don't forget change this**

Login to
- http://localhost:8080/svnadmin (login: `admin` / password: `admin` **Don't forget change this** )

## Create a first repository
- Login to http://localhost:8080/svnadmin
- Use *Repositories* -> *Add* to create a first repository `<reponame>`
- Use *Users* -> *Add* to create a first user `<user>`
- Use *Access-Paths* and assign *read-write* privileges for `user` to repository `<reponame>`  
The screenshot assigns user `alex` `read-write` privileges to repository `test`.  
![Access-Paths](/misc/access-path.jpg)

## Checkout on host machine
Finally try to checkout a repository on your host machine:
```bash
$ cd <checkout>
# easy
$ svn checkout http://localhost:8080/svn/<reponame>
# with explicit username
$ svn checkout --username <user> http://localhost:8080/svn/<reponame>
```

## Commit
```bash
$ cd <checkout>/<reponame>
$ touch test.txt
$ svn add test.txt
$ svn commit -m "initial commit"
```

## Web frontends
Check the functionality by opening
- http://localhost:8080/svn
- optional: http://localhost:8080/websvn

within your favorite webbrowser.

# Configuration
It's recommended to use **svnadmin** to create user accounts/repositories.

For further information on how to configure Subversion, please refer to the [official web page](https://subversion.apache.org/).
