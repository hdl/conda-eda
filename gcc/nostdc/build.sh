#!/bin/bash

# gcc bare metal build
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
GCC=$TARGET-gcc

# Check binutils
$TARGET-as --version

#set -x

rm -rf libstdc++-v3
cd ..


mkdir -p build-gcc
cd build-gcc

# --without-headers - Tells GCC not to rely on any C library (standard or runtime) being present for the target.
#CFLAGS="$CFLAGS -Wno-literal-suffix"
#export LDFLAGS=-static
mkdir -p $PREFIX/$TARGET/sysroot/usr/include

$SRC_DIR/gcc/configure \
	\
        --prefix=/ \
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


make -j$CPU_COUNT
make DESTDIR=${PREFIX} install-strip

# Install aliases for XXX-unknown-elf name
for EXE in $(ls $PREFIX/bin/$TARGET-* | grep /$TARGET-); do
	UNKNOWN_EXE="$(echo $EXE | sed -e"s_/$TARGET-_/${TOOLCHAIN_ARCH}-unknown-elf-_")"

	if [ ! -e "$UNKNOWN_EXE" ]; then
		ln -sv "$EXE" "$UNKNOWN_EXE"
	fi
done
ls -l $PREFIX/bin/${TOOLCHAIN_ARCH}-unknown-elf-*

cd ..

$PREFIX/bin/$TARGET-gcc --version
$PREFIX/bin/${TOOLCHAIN_ARCH}-unknown-elf-gcc --version

echo $($PREFIX/bin/$TARGET-gcc --version 2>&1 | head -1 | sed -e"s/$TARGET-gcc (GCC) //")
