#!/bin/bash

set -xeu

RUBY_X_Y_VERSION=$1
SPEC_FILE=ruby-${RUBY_X_Y_VERSION}.spec
RUBY_X_Y_Z_VERSION=$(grep '^Version: ' ~/ruby-rpm/${SPEC_FILE} | awk '{ print $NF }')
ARCH=$(uname -m)

cp ~/ruby-rpm/${SPEC_FILE} ~/rpmbuild/SPECS/

cd ~/rpmbuild/SOURCES
curl -LO https://cache.ruby-lang.org/pub/ruby/${RUBY_X_Y_VERSION}/ruby-${RUBY_X_Y_Z_VERSION}.tar.gz

rpmbuild -ba ~/rpmbuild/SPECS/${SPEC_FILE}

DEST_DIR=/tmp/ruby-${RUBY_X_Y_VERSION}-rpm
mkdir -p ${DEST_DIR}
cp ~/rpmbuild/RPMS/${ARCH}/* ${DEST_DIR}
cp ~/rpmbuild/SRPMS/* ${DEST_DIR}
