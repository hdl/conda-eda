#!/bin/bash

set -e
set -x

# Build musl libc
# ============================================================

unset AS
unset AR
unset ADDR2LINE
unset CC
unset CFLAGS
unset CPP
unset CPPFLAGS
unset DEBUG_CPPFLAGS
unset CXX
unset CXXFLAGS
unset DEBUG_CXXFLAGS
unset GCC
unset GCC_AR
unset GCC_NM
unset GCC_RANLIB
unset GPROF
unset GXX
unset LD
unset LDFLAGS
unset LD_GOLD
unset LD_RUN_PATH
unset RANLIB
unset READELF
unset SIZE
unset STRINGS
unset STRIP

export PATH=${PREFIX}/bin:$PATH
# GCC_EXEC_PREFIX
# COMPILER_PATH

# Configure musl
mkdir -p $SRC_DIR/build-musl
cd $SRC_DIR/build-musl
$SRC_DIR/musl/configure \
	\
	--target=$LINUX_TARGET \
	\
	--prefix=$SYSROOT \
	--with-sysroot=$SYSROOT \
	\
	--disable-multilib \
	\

# Build libc (musl)
mkdir -p $SRC_DIR/build-musl
cd $SRC_DIR/build-musl
make -j$CPU_COUNT

# Install libc
mkdir -p $SRC_DIR/build-musl
cd $SRC_DIR/build-musl
make install

echo
echo
echo "--------------------------------------------"
find $SYSROOT | sort
echo "--------------------------------------------"
echo
echo
