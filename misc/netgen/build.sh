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

export

echo
echo PREFIX
echo "---------------------"
find ${PREFIX} -name tclConfig.sh
echo "---------------------"

echo CPPFLAGS="$CPPFLAGS"

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/autoconf/build-aux/config.* scripts

if [ "$OS" = "Linux" ]; then
	./configure \
		--prefix="${PREFIX}" \
		--with-tk="${PREFIX}" \
		--with-tcl="${PREFIX}" \
		--x-includes="${PREFIX}" \
		--x-libraries="${PREFIX}"
elif [ "$OS" = "Mac" ]; then
	./configure \
		--prefix="${PREFIX}" \
		--with-tk="${PREFIX}" \
		--with-tcl="${PREFIX}" \
		--without-x
fi

echo "Configure ended with: $?"
make V=1 -j$NUM_CORES || exit 1

make V=1 install || exit 1
