[![Docker Image](https://img.shields.io/badge/Docker%20Image-available-success&style=flat)](https://hub.docker.com/r/userid0x0/svn-docker/)
[![Build](https://img.shields.io/github/actions/workflow/status/userid0x0/svn-docker/docker-image.yml?branch=master&label=build&logo=github&style=flat)](https://github.com/userid0x0/svn-docker/actions)

It's a fork of https://github.com/elleFlorio/svn-docker & https://github.com/sea-kg/svn-docker

# Description
Lightweight container providing an SVN server, based on **Alpine Linux** and S6 process management (see [here](https://github.com/crazy-max/docker-alpine-s6) for details).
The access to the server is possible via **WebDav protocol** (http://).

Components:
- Alpine Linux (3.17) with S6 Overlay (3.1.1.2)
- svn + apache taken from Alpine Linux<br>SVN is build from a intermediate state as `svnauthz` is required
- iF.SVNAdmin web-interface used from [https://github.com/mfreiholz/iF.SVNAdmin](https://github.com/mfreiholz/iF.SVNAdmin)
<br>version: 1.6.2 + some patches for PHP8.2
- WebSVN web-interface used from [https://github.com/websvnphp/websvn](https://github.com/websvnphp/websvn)<br>version: 2.8.1
- Repos-Web XSLT Stylesheet used from [https://github.com/rburgoyne/repos-style](https://github.com/rburgoyne/repos-style)


# How to run
To run the image, you can use the following command:
```
docker run \
    --name svn-server \
    -p 8080:80 \
    -e SVN_SERVER_REPOSITORIES_URL=/svn \
    -e WEBSVN_URL=/websvn \
    -e WEBSVN_AUTH=2 \
    -v `pwd`/data:/data \
    docker.io/userid0x0/svn-docker
```

## Environment variables
- `SVN_SERVER_REPOSITORIES_URL` location of the SVN repo on the web interface<br>default: `/svn`
- `WEBSVN_URL` location of the WebSVN web interface<br>default: `/websvn`<br>websvn will be disabled when the URL is empty
- `WEBSVN_AUTH` authentification used for WebSVN<br>default: `2`
    - `0` no authentification used (public access)
    - `1` read access for all known users for all repositories
    - `2` read access to all known users repecting svnauthz (e.g. controlled via iF.SVNAdmin)
## Volume `/data`
- `<data>/repositories` - will be keep all repositories in subfolder in data
- `<data>/subversion` - configurations for subversion (passwd && subversion-access-control)
- `<data>/svnadmin` - svnadmin related
- `<data>/websvn` - websvn related

## Building
```
docker build --tag localhost/svn-docker .
```

## URLs
- http://localhost:8080/svnadmin - configuration
- http://localhost:8080/svn - with repositories
- http://localhost:8080/websvn - websvn access

# First start
With the first start `/data` will be inited automatically - folders/files/password - for easy start.

Login to
- http://localhost:8080/svnadmin (login: `admin` / password: `admin` **Don't forget change this** )

and create users & repositories. Check the functionality by opening
- http://localhost:8080/svn
- optional: http://localhost:8080/websvn

within your favorite webbrowser.

Finally try to checkout a repository on your host machine:
```
svn checkout http://localhost:8080/svn/<reponame>
```

# Configuration
It's recommended to use **svnadmin** to create user accounts/repositories.

For further information on how to configure Subversion, please refer to the [official web page](https://subversion.apache.org/).
