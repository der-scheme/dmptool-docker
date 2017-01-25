# Installation instructions

## Prerequisites

 1. GNU/Linux x86_64 host with Docker (if docker < v1.13, should have
    docker-compose installed). 32 bit should work as well, but requires you to
    modify paths in supervisor.conf, at the least.
 2. MySQL/MariaDB database, either on the host, or any other system (a container
    is fine, too)

## Building the image

Run `docker build` from the project root (the directory where the Dockerfile
resides). The following build args are supported:

 1. **GIT**=*https://github.com/der-scheme/dmptool.git* –
    the git repository to pull the web app from
 2. **RELEASE**=*freiburg* –
    the web app release. This can be a git branch, a specific commit or a tag
 3. **HTTP_PORT**=*80* –
    the port the HTTP server should listen on
 4. **HTTPS_PORT**=*443* –
    the port the HTTPS server should listen on

## Installation

 1. Either build the image yourself, or get a prebuilt version from somewhere.
 2. Setup image. # TODO
 3. Configure the image (see **doc.md** for instructions).
 4. Start image. #TODO
