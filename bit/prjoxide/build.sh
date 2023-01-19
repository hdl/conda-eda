#!/bin/bash

set -e
set -x

# Using conda packages for capnproto and capnproto-java does
# not seem to work when compiling prjoxide.
curl -O https://capnproto.org/capnproto-c++-0.8.0.tar.gz
tar zxf capnproto-c++-0.8.0.tar.gz
pushd capnproto-c++-0.8.0
./configure
make -j`nproc` check
sudo make install
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
popd

git clone https://github.com/capnproto/capnproto-java.git
pushd capnproto-java
make -j`nproc`
sudo make install
popd

curl --proto '=https' -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

cd libprjoxide
cargo install --path prjoxide --all-features --root $PREFIX
