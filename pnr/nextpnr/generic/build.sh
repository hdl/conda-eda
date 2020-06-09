#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
    CPU_COUNT=2
else
    # Identify OS
    UNAME_OUT="$(uname -s)"
    case "${UNAME_OUT}" in
    Linux*)     OS=Linux;;
    Darwin*)    OS=Mac;;
    *)          OS="${UNAME_OUT}"
                echo "Unknown OS: ${OS}"
                exit;;
    esac

    if [[ $OS == "Linux" ]]; then
        CPU_COUNT=$(nproc)
    elif [[ $OS == "Mac" ]]; then
        CPU_COUNT=$(sysctl -n hw.physicalcpu)
    fi
fi

cmake -DARCH=generic -DBUILD_GUI=OFF -DCMAKE_INSTALL_PREFIX=/ -DENABLE_READLINE=No .
make -k -j${CPU_COUNT} || true
make

make DESTDIR=${PREFIX} install
