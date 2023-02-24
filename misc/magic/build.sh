#!/bin/bash

set -e
set -x

# Identify OS
UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     OS=Linux;;
    Darwin*)    OS=Mac;;
    *)          OS="${UNAME_OUT}"
                echo "Unknown OS: ${OS}"
                exit;;
esac

if [ "$OS" = "Linux" ]; then
    ./configure --prefix="${PREFIX}" --with-cairo="${BUILD_PREFIX}/include"
elif [ "$OS" = "Mac" ]; then
    ./configure --prefix="${PREFIX}" --without-cairo --without-opengl --without-x
fi

make V=1 -j$CPU_COUNT

make V=1 install
