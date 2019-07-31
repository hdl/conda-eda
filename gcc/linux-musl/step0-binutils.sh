#!/bin/bash

set -e
set -x

# Binutils
# ============================================================

# Configure binutils
mkdir -p $SRC_DIR/build-binutils
cd $SRC_DIR/build-binutils
../binutils/configure \
	\
	--target=$LINUX_TARGET \
	\
	--prefix=$PREFIX \
	--with-sysroot=$SYSROOT \
	\
	--disable-nls \
	--disable-werror \
	--enable-deterministic-archives \


# Build binutils
mkdir -p $SRC_DIR/build-binutils
cd $SRC_DIR/build-binutils

make -j$CPU_COUNT

# Install binutils
make install-strip

# Check binutils
cd $SRC_DIR
echo -n "---?"
which $LINUX_TARGET-as
ls -l $(which $LINUX_TARGET-as)
file $(which $LINUX_TARGET-as)
echo "---"
$LINUX_TARGET-as --version 2>&1
echo "---"
