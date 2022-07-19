#!/bin/bash

set -e
set -x

which pkg-config

echo "PREFIX := $PREFIX" >> Makefile.conf

make UHDM_INSTALL_DIR=$PREFIX install -j$CPU_COUNT
