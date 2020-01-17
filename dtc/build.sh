#!/bin/bash

# binutils build
set -e
set -x

pkg-config --cflags python3; echo $?
which swig; echo $?

make
make install PREFIX=$PREFIX

make pylibfdt EXTRA_CFLAGS="-Wno-error=cast-qual -Wno-error=missing-prototypes -Wno-error=shadow"
make install_pylibfdt EXTRA_CFLAGS="-Wno-error=cast-qual -Wno-error=missing-prototypes -Wno-error=shadow" PREFIX=$PREFIX
