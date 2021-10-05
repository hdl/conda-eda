#! /bin/bash

set -x
set -e

make
install -D bin/sv2v $PREFIX/bin/zachjs-sv2v

