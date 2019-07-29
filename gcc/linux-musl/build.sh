#!/bin/bash

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
echo "============================================================"
echo
echo
echo "Source directory ==========================================="
echo $SRC_DIR
ls -l $SRC_DIR
echo "============================================================"
echo
echo

export LINUX_TARGET=${TOOLCHAIN_ARCH}-linux-musl
export SYSROOT=$PREFIX/$LINUX_TARGET/sysroot
mkdir -p $SYSROOT/include
mkdir -p $SYSROOT/lib
ln -sf $SYSROOT $SYSROOT/usr

# Binutils
bash $RECIPE_DIR/step0-binutils.sh
bash $RECIPE_DIR/step1-stage1-gcc.sh
bash $RECIPE_DIR/step2-headers.sh
bash $RECIPE_DIR/step3-stage2-gcc.sh
bash $RECIPE_DIR/step4-libc.sh

# Check GCC
echo -n "---?"
which $LINUX_TARGET-gcc
ls -l $(which $LINUX_TARGET-gcc)
file $(which $LINUX_TARGET-gcc)
echo "---"
$LINUX_TARGET-gcc --version 2>&1
echo "---"

$PREFIX/bin/$LINUX_TARGET-gcc --version
echo $($PREFIX/bin/$LINUX_TARGET-gcc --version 2>&1 | head -1 | sed -e"s/$LINUX_TARGET-gcc (GCC) //")

find $PREFIX | sort

bash $RECIPE_DIR/run_test.sh || true
