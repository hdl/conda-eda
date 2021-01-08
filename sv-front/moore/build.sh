#!/bin/bash

set -e
set -x

curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

cargo build --release
install -D target/release/moore $PREFIX/bin/moore

$PREFIX/bin/moore --version
