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



# generate specfile so that we can patch loader link path
# link_libgcc should have the gcc's own libraries by default (-R)
# so that LD_LIBRARY_PATH isn't required for basic libraries.
#
# GF method here to create specs file and edit it.  The other methods
# tried had no effect on the result.  including:
#   setting LINK_LIBGCC_SPECS on configure
#   setting LINK_LIBGCC_SPECS on make
#   setting LINK_LIBGCC_SPECS in gcc/Makefile
specdir=$(dirname $($PREFIX/bin/${LINUX_TARGET}-gcc -print-libgcc-file-name))
$PREFIX/bin/${LINUX_TARGET}-gcc -dumpspecs > $specdir/specs || true
# We use double quotes here because we want $PREFIX and $CHOST to be expanded at build time
#   and recorded in the specs file.  It will undergo a prefix replacement when our compiler
#   package is installed.
sed -i -e "/\*link_libgcc:/,+1 s+%.*+& -rpath ${PREFIX}/lib+" $specdir/specs || true
