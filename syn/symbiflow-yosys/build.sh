#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

#unset CFLAGS
#unset CXXFLAGS
#unset CPPFLAGS
#unset DEBUG_CXXFLAGS
#unset DEBUG_CPPFLAGS
#unset LDFLAGS

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
        echo "ENABLE_READLINE := 0" >> Makefile.conf
fi

echo "PREFIX := $PREFIX" >> Makefile.conf

make V=1 -j$CPU_COUNT
if [[ $OS == "Linux" ]]; then
        make test
fi
make install
