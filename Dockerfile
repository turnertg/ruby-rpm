#
# base image
#

FROM centos:7 AS base
MAINTAINER feedforce Inc.

# setup
RUN yum install -y rpm-build tar make

# ruby depends
RUN yum -y install readline-devel ncurses-devel gdbm-devel glibc-devel gcc openssl-devel libyaml-devel libffi-devel zlib-devel

#
# builder image
#

FROM base AS builder

ARG RUBY_X_Y_VERSION

# rpmbuild command recommends to use `builder:builder` as user:group.
RUN useradd -u 1000 builder

RUN mkdir -p /home/builder/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
RUN mkdir -p /home/builder/ruby-rpm
RUN chown -R builder:builder /home/builder/rpmbuild
RUN chown -R builder:builder /home/builder/ruby-rpm

WORKDIR /home/builder/ruby-rpm
USER builder

COPY . /home/builder/ruby-rpm/
RUN /home/builder/ruby-rpm/scripts/build-rpm.sh $RUBY_X_Y_VERSION

#
# tester image
#

FROM base AS tester

ARG RUBY_X_Y_VERSION

COPY --from=builder /tmp/ruby-$RUBY_X_Y_VERSION-rpm /tmp/ruby-$RUBY_X_Y_VERSION-rpm
RUN yum install -y /tmp/ruby-$RUBY_X_Y_VERSION-rpm/ruby-$RUBY_X_Y_VERSION.*.$(uname -m).rpm

# test for passenger dependency checks
RUN yum install -y pygpgme curl epel-release yum-utils
RUN yum-config-manager --enable epel
RUN curl --fail -sSLo /etc/yum.repos.d/passenger.repo https://oss-binaries.phusionpassenger.com/yum/definitions/el-passenger.repo
RUN yum update -y
RUN yum install -y mod_passenger
