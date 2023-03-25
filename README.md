It's a fork of https://github.com/elleFlorio/svn-docker & https://github.com/sea-kg/svn-docker

# Description
Lightweight container providing an SVN server, based on **Alpine Linux** and S6 process management (see [here](https://github.com/crazy-max/docker-alpine-s6) for details).
The access to the server is possible via **WebDav protocol** (http://)

Svnadmin web-interface used from [https://github.com/mfreiholz/iF.SVNAdmin](https://github.com/mfreiholz/iF.SVNAdmin) version: 1.6.2 + some patches for PHP8.2
WebSVN web-interface used from [https://github.com/websvnphp/websvn](https://github.com/websvnphp/websvn) version: 2.8.1


# Running Commands
To run the image, you can use the following command:
```
docker run \
    --name svn-server \
    -p 80:80 \
    -e SVN_SERVER_REPOSITORIES_URL=/svn \
    -e WEBSVN_URL=/websvn \
    -e WEBSVN_AUTH=2 \
    -v `pwd`/data:/data \
    <your tag>
```

### Volume /data
- `<data>/repositories` - will be keep all repositories in subfolder in data
- `<data>/subversion` - configurations for subversion (passwd && subversion-access-control)
- `<data>/svnadmin` - svnadmin related
- `<data>/websvn` - websvn related

In first start will be inited automatically all default folders/files/password - to easy start.

so:

- http://localhost/svn - with repositories
- http://localhost/svnadmin - configuration (login: `admin` / password: `admin` **Don't forget change this** )
- http://localhost/websvn - websvn access



Check also that the custom protocol is working fine: go to your terminal and type `svn info svn://localhost:3690`. The system should connect to the server and tell you that is not able to find any repository.
For further information on how to configure Subversion, please refer to the [official web page](https://subversion.apache.org/).
