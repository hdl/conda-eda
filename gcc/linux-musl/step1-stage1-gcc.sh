#!/bin/bash

set -e
set -x

# Stage 1 GCC
# ============================================================
export CFLAGS="$CFLAGS -O0 -g0"
export CXXFLAGS="$CXXFLAGS -O0 -g0"

# Configure GCC
mkdir -p $SRC_DIR/build-gcc1
cd $SRC_DIR/build-gcc1
$SRC_DIR/gcc/configure \
	\
	--target=$LINUX_TARGET \
	\
	--prefix=$PREFIX \
	--with-sysroot=$SYSROOT \
	\
	--program-prefix=$LINUX_TARGET- \
	\
	--with-pkgversion=$PKG_VERSION \
	--enable-languages="c" \
	--disable-multilib \
	\
	--without-headers \
	\
	--disable-nls \
	--disable-libatomic \
	--disable-libgcc \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libquadmath \
	--disable-libssp \
	--disable-nls \
	--disable-shared \
	--disable-tls \
	\

# Build GCC
mkdir -p $SRC_DIR/build-gcc1
cd $SRC_DIR/build-gcc1
make -j$CPU_COUNT

# Install GCC
mkdir -p $SRC_DIR/build-gcc1
cd $SRC_DIR/build-gcc1
make install-strip

# Check GCC
cd $SRC_DIR
echo -n "---?"
which $LINUX_TARGET-gcc
ls -l $(which $LINUX_TARGET-gcc)
file $(which $LINUX_TARGET-gcc)
echo "---"
$LINUX_TARGET-gcc --version 2>&1
echo "---"
