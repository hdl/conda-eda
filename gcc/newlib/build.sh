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

TARGET=${TOOLCHAIN_ARCH}-elf
GCC=$TARGET-newlib-gcc

# Check binutils
$TARGET-as --version

# Check the "nostdc" gcc is already installed
echo -n "---?"
which $TARGET-gcc
ls -l $(which $TARGET-gcc)
file $(which $TARGET-gcc)
echo "---"
$TARGET-gcc --version 2>&1
echo "---"

GCC_STAGE1_VERSION=$($TARGET-gcc --version 2>&1 | head -1 | sed -e"s/$TARGET-gcc (//" -e"s/).*//")
GCC_STAGE2_VERSION=$(echo $PKG_VERSION | sed -e's/-.*//')
if [ "$GCC_STAGE1_VERSION" != "$GCC_STAGE2_VERSION" ]; then
	echo
	echo "nostdc version: $GCC_STAGE1_VERSION"
	echo "  this version: $GCC_STAGE2_VERSION"
	echo
	echo "Stage 1 compiler (nostdc) not the same version as us!"
	echo
 	exit 1
fi

#set -x

rm -rf libstdc++-v3
cd ..

mkdir -p build-newlib
cd build-newlib
$SRC_DIR/newlib/configure \
	--target=$TARGET \
	\
        --prefix=/ \
	\
	--disable-newlib-supplied-syscalls \
	\
	--enable-multilib \
	\

make -j$CPU_COUNT
make DESTDIR=$PREFIX install
cd ..

mkdir -p build-gcc
cd build-gcc

#export LDFLAGS=-static
#        --prefix=$PREFIX \
$SRC_DIR/gcc/configure \
	\
        --prefix=/ \
	--program-prefix=$TARGET-newlib- \
	\
        --with-gmp=$CONDA_PREFIX \
        --with-mpfr=$CONDA_PREFIX \
        --with-mpc=$CONDA_PREFIX \
        --with-isl=$CONDA_PREFIX \
        --with-cloog=$CONDA_PREFIX \
	\
	--target=$TARGET \
	--with-pkgversion=$PKG_VERSION \
	--enable-languages="c" \
	--enable-threads=single \
	--enable-multilib \
	\
	--with-newlib \
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


make -j$CPU_COUNT
make DESTDIR=${PREFIX} install-strip

# Install aliases for the binutil tools
for BINUTIL in $(ls $PREFIX/bin/$TARGET-* | grep /$TARGET-); do
	NEWLIB_BINUTIL="$(echo $BINUTIL | sed -e"s_/$TARGET-_/$TARGET-newlib-_" -e's/newlib-newlib/newlib/')"

	if [ ! -e "$NEWLIB_BINUTIL" ]; then
		ln -sv "$BINUTIL" "$NEWLIB_BINUTIL"
	fi
done
ls -l $PREFIX/bin/$TARGET-newlib-*

cd ..

$PREFIX/bin/$TARGET-gcc --version
$PREFIX/bin/${TOOLCHAIN_ARCH}-unknown-elf-gcc --version
$PREFIX/bin/$TARGET-newlib-gcc --version

echo $($PREFIX/bin/$TARGET-newlib-gcc --version 2>&1 | head -1 | sed -e"s/$TARGET-gcc (GCC) //")
