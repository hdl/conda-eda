#!/bin/bash

# gcc newlib build
set -e

if [ -z "${TOOLCHAIN_ARCH}" ]; then
	export | grep -i toolchain
	echo "Missing \${TOOLCHAIN_ARCH} env value"
	exit 1
else
	echo "TOOLCHAIN_ARCH: '$TOOLCHAIN_ARCH'"
fi
if [ x"$PKG_VERSION" = x ]; then
	export | grep version
	export | grep VERSION
	exit 1
else
	echo "PKG_VERSION: '$PKG_VERSION'"
fi

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi
echo
echo
echo "============================================================"
echo "CFLAGS='$CFLAGS'"
echo "CXXFLAGS='$CXXFLAGS'"
echo "CPPFLAGS='$CPPFLAGS'"
echo "DEBUG_CXXFLAGS='$DEBUG_CXXFLAGS'"
echo "DEBUG_CPPFLAGS='$DEBUG_CPPFLAGS'"
echo "LDFLAGS='$LDFLAGS'"
echo "------------------------------------------------------------"
export CFLAGS="$(echo $CFLAGS) -w"
export CXXFLAGS="$(echo $CXXFLAGS | sed -e's/-std=c++17 //') -w"
export CPPFLAGS="$(echo $CPPFLAGS | sed -e's/-std=c++17 //')"
export DEBUG_CXXFLAGS="$(echo $DEBUG_CXXFLAGS | sed -e's/-std=c++17 //') -w"
export DEBUG_CPPFLAGS="$(echo $DEBUG_CPPFLAGS | sed -e's/-std=c++17 //')"
echo "CFLAGS='$CFLAGS'"
echo "CXXFLAGS='$CXXFLAGS'"
echo "CPPFLAGS='$CPPFLAGS'"
echo "DEBUG_CXXFLAGS='$DEBUG_CXXFLAGS'"
echo "DEBUG_CPPFLAGS='$DEBUG_CPPFLAGS'"
echo "LDFLAGS='$LDFLAGS'"
echo "------------------------------------------------------------"
export
echo "============================================================"
echo
echo
echo "Start directory ============================================"
echo $PWD
ls -l $PWD
echo "------------------------------------------------------------"
ls -l $PWD/*
echo "============================================================"
echo
echo
echo "Source directory ==========================================="
echo $SRC_DIR
ls -l $SRC_DIR
echo "------------------------------------------------------------"
ls -l $SRC_DIR/*
echo "============================================================"
echo
echo

cat > config.mak <<EOF
TARGET=${TOOLCHAIN_ARCH}-linux-musl
OUTPUT=${PREFIX}
BINUTILS_VER=${binutils_version}
GCC_VER=${gcc_version}
MUSL_VER=${musl_version}
LINUX_VER=${linux_version}

GCC_CONFIG += --enable-languages=c

MUSL_CONFIG += CFLAGS="" CPPFLAGS="" DEBUG_CPPFLAGS="" CXXFLAGS="" DEBUG_CXXFLAGS="" LDFLAGS=""

EOF
echo "============================================================"
cat config.mak
echo "============================================================"

make -j$CPU_COUNT
make install
ls -l $PREFIX/$TOOLCHAIN_ARCH-linux-musl/lib/ld-musl-*
rm -f $PREFIX/$TOOLCHAIN_ARCH-linux-musl/lib/ld-musl-$TOOLCHAIN_ARCH*.so.1
ln -sf $PREFIX/$TOOLCHAIN_ARCH-linux-musl/lib/libc.so $PREFIX/$TOOLCHAIN_ARCH-linux-musl/lib/ld-musl-$TOOLCHAIN_ARCH*.so.1
