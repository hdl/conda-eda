#!/bin/bash

set -e
set -x

which pkg-config

# Identify OS
UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     OS=Linux;;
    Darwin*)    OS=Mac;;
    *)          OS="${UNAME_OUT}"
                echo "Unknown OS: ${OS}"
                exit;;
esac
echo "Build started for ${OS}..."

if [[ $OS == "Linux" ]]; then
	make config-conda-linux
elif [[ $OS == "Mac" ]]; then
	make config-conda-mac
fi

echo "PREFIX := $PREFIX" >> Makefile.conf
echo "ENABLE_READLINE := 0" >> Makefile.conf

make V=1 -j$CPU_COUNT
make install

$PREFIX/bin/yosys -V
$PREFIX/bin/yosys-abc -v 2>&1 | grep compiled
