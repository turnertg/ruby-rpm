[![CircleCI](https://circleci.com/gh/feedforce/ruby-rpm.svg?style=shield)](https://circleci.com/gh/feedforce/ruby-rpm)

# What is this spec?

Forked from hansode's ruby-2.1.x-rpm project at https://github.com/hansode/ruby-2.1.x-rpm and updated for 2.2.2.

# build SRPM and RPM

It's Simple.

1. Create your feature branch named `ruby-{major}.{minor}.{patch}` (e.g ruby-2.2.4)
2. Edit `ruby-{major}.{minor}.spec`
    - Change value of `Version`
    - Add Changelog
3. Push to the branch.
4. Create a Pull request.
5. When the Pull request is merged, CircleCI will release ruby rpms to https://github.com/feedforce/ruby-rpm/releases .

## Automation

We create a Pull Request automatically using CircleCI.

# About Docker Image

This project uses Docker to build RPMs.

The Docker images are hosted at [Docker Hub](https://hub.docker.com/).

- For CentOS 7: [`feedforce/ruby-rpm:centos7`](https://hub.docker.com/r/feedforce/ruby-rpm/)

## How to build and push Docker image

### Manually

You can also build Docker images manually.

```
$ docker login
$ docker buildx create --use
$ docker buildx build \
    -t feedforce/ruby-rpm:centos7 \
    -f Dockerfile-7 \
    --target base \
    --platform=linux/amd64,linux/arm64 \
    --push \
    .
```
