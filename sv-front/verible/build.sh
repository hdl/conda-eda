#! /bin/bash

set -e
set -x

export CC=gcc-${USE_SYSTEM_GCC_VERSION}
export CXX=g++-${USE_SYSTEM_GCC_VERSION}


mkdir bazel-install
BAZEL_PREFIX=$PWD/bazel-install
BAZEL_VERSION=5.3.0

wget https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh
chmod +x bazel-$BAZEL_VERSION-installer-linux-x86_64.sh
./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh --prefix=$BAZEL_PREFIX

export PATH=$BAZEL_PREFIX/bin:$PATH

bazel run :install -c opt -- $PREFIX/bin
