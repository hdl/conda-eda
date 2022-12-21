#!/bin/bash

set -e
set -x

# Identify OS
UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     OS=Linux;;
    *)          OS="${UNAME_OUT}"
                echo "Unknown OS: ${OS}"
                exit;;
esac

cd $SRC_DIR/xpm
./configure --prefix="${PREFIX}" --without-localedir
make V=1 -j$CPU_COUNT
make V=1 install

cd $SRC_DIR
./configure --prefix="${PREFIX}" --prefix/libs/script/tcl="${PREFIX}" --prefix/libs/gui/xpm="${PREFIX}"
make V=1 -j$CPU_COUNT
make V=1 install
