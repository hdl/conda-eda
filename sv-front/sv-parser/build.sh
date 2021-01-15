#!/bin/bash

set -e
set -x

curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

cargo build --example parse_sv --release
install -D target/release/examples/parse_sv $PREFIX/bin/parse_sv

$PREFIX/bin/parse_sv --version
