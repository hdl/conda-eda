#!/bin/bash

set -e
set -x

which pkg-config

echo "PREFIX := $PREFIX" >> Makefile.conf

# These are set properly by Makefile but only if not present.
unset CXX CXXFLAGS LDLIBS LDFLAGS

make UHDM_INSTALL_DIR=$PREFIX install -j$CPU_COUNT
