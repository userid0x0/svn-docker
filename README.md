[![Docker Image](https://img.shields.io/badge/docker%20image-available-green.svg)](https://hub.docker.com/r/elleflorio/svn-server/)

# Description
Lightweight container providing an SVN server, based on **Alpine Linux** and S6 process management (see [here](https://github.com/smebberson/docker-alpine) for details).
The access to the server is possible via **WebDav protocol** (http://), and via **custom protocol** (svn://).
A complete tutorial on how to build this image, and how to run the container is available on [Medium](https://medium.com/@elle.florio/the-svn-dockerization-84032e11d88d#.bafh3otmh)

# Running Commands
To run the image, you can use the following command:
```
docker run -d \
    --name svn-server \
    -p 80:80 \
    -p 3690:3690 \
    -v `pwd`/data:/data \
    elleflorio/svn-server
```

- `<data>/svnadmin` - will be keep all repositories in subfolder in data
- `<data>/repositories` - will be keep all repositories in subfolder in data
- `<data>/subversion` - configurations for subversion (passwd && subversion-access-control)

In first start will be inited automaticly all default folders/files/password - to easy start.

so:

- http://localhost/svn - with repositories
- http://localhost/svnadmin - configuration (login: `admin` / password: `admin` **Don't foget change this** )



Check also that the custom protocol is working fine: go to your terminal and type `svn info svn://localhost:3690`. The system should connect to the server and tell you that is not able to find any repository.
For further information on how to configure Subversion, please refer to the [official web page](https://subversion.apache.org/).


## TODO:

- fix to deny access `/svnadmin/data/`
- fix access via `svn://` by port 3690 (some problem with access)
