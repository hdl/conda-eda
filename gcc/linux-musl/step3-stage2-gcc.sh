#!/bin/bash

set -e
set -x

# Stage 2 GCC
# ============================================================

# Configure GCC
mkdir -p $SRC_DIR/build-gcc2
cd $SRC_DIR/build-gcc2
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
	--with-musl \
	\
	--disable-nls \
	--disable-libatomic \
	--enable-libgcc \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libquadmath \
	--disable-libssp \
	--disable-nls \
	--disable-shared \
	--disable-tls \
	\
	--with-gmp=$CONDA_PREFIX \
	--with-mpfr=$CONDA_PREFIX \
	--with-mpc=$CONDA_PREFIX \
	--with-isl=$CONDA_PREFIX \
	--with-cloog=$CONDA_PREFIX \
	\

# Build GCC
mkdir -p $SRC_DIR/build-gcc2
cd $SRC_DIR/build-gcc2
make -j$CPU_COUNT

# Install GCC
mkdir -p $SRC_DIR/build-gcc2
cd $SRC_DIR/build-gcc2
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
