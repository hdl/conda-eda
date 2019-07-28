#!/bin/bash

# gcc linux-musl build
set -e
set -x

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

METAL_TARGET=${TOOLCHAIN_ARCH}-elf
LINUX_TARGET=${TOOLCHAIN_ARCH}-linux-musl

# ============================================================

# Check the "nostdc" gcc is already installed
echo -n "---?"
which $METAL_TARGET-gcc
ls -l $(which $METAL_TARGET-gcc)
file $(which $METAL_TARGET-gcc)
echo "---"
$METAL_TARGET-gcc --version 2>&1
echo "---"

GCC_STAGE1_VERSION=$($METAL_TARGET-gcc --version 2>&1 | head -1 | sed -e"s/$METAL_TARGET-gcc (//" -e"s/).*//")
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

cd ..

# ============================================================

case "${TOOLCHAIN_ARCH}" in
	riscv*)	LINUX_ARCH=riscv 	;;
	or1k*)	LINUX_ARCH=openrisc	;;
	sh*)	LINUX_ARCH=sh		;;
esac
export LINUX_ARCH

cd $SRC_DIR/kernel-headers
make defconfig ARCH=$LINUX_ARCH
mkdir -p $PREFIX/$LINUX_TARGET/include
mkdir -p $PREFIX/$LINUX_TARGET/usr
ln -s $PREFIX/$LINUX_TARGET/include $PREFIX/$LINUX_TARGET/usr/include
make headers_install ARCH=$LINUX_ARCH INSTALL_HDR_PATH=$PREFIX/$LINUX_TARGET/include
find $PREFIX/$LINUX_TARGET | sort

# ============================================================

# Configure binutils
mkdir -p $SRC_DIR/build-binutils
cd $SRC_DIR/build-binutils
../binutils/configure \
	--target=$LINUX_TARGET \
	\
	--prefix=/ \
	--with-sysroot=$PREFIX/$LINUX_TARGET \
	\
	--disable-nls \
	--disable-werror \
	--enable-deterministic-archives \


# Build binutils
mkdir -p $SRC_DIR/build-binutils
cd $SRC_DIR/build-binutils

make -j$CPU_COUNT
make DESTDIR=${PREFIX} install-strip

cd ..

# Check binutils
cd $SRC_DIR
echo -n "---?"
which $LINUX_TARGET-as
ls -l $(which $LINUX_TARGET-as)
file $(which $LINUX_TARGET-as)
echo "---"
$LINUX_TARGET-as --version 2>&1
echo "---"

# ============================================================

# Configure GCC
mkdir -p $SRC_DIR/build-gcc
cd $SRC_DIR/build-gcc
$SRC_DIR/gcc/configure \
	\
        --prefix=/ \
	--with-sysroot=$PREFIX/$LINUX_TARGET \
	\
	--program-prefix=$LINUX_TARGET- \
	\
        --with-gmp=$CONDA_PREFIX \
        --with-mpfr=$CONDA_PREFIX \
        --with-mpc=$CONDA_PREFIX \
        --with-isl=$CONDA_PREFIX \
        --with-cloog=$CONDA_PREFIX \
	\
	--target=$LINUX_TARGET \
	--with-pkgversion=$PKG_VERSION \
	--enable-languages="c" \
	--enable-multilib \
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

# Build GCC
mkdir -p $SRC_DIR/build-gcc
cd $SRC_DIR/build-gcc

make -j$CPU_COUNT
make DESTDIR=${PREFIX} install-strip

# Check GCC
cd $SRC_DIR
echo -n "---?"
which $LINUX_TARGET-gcc
ls -l $(which $LINUX_TARGET-gcc)
file $(which $LINUX_TARGET-gcc)
echo "---"
$LINUX_TARGET-gcc --version 2>&1
echo "---"

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

echo "========================================================="
$PREFIX/bin/$LINUX_TARGET-gcc --version
$PREFIX/bin/$LINUX_TARGET-gcc -print-search-dirs
$PREFIX/bin/$LINUX_TARGET-gcc -print-prog-name=as
echo "========================================================="

export CROSS_COMPILE="$LINUX_TARGET-"
export CC="$LINUX_TARGET-gcc"

# ============================================================

# Configure musl
mkdir -p $SRC_DIR/build-musl
cd $SRC_DIR/build-musl
$SRC_DIR/musl/configure \
	\
	--target=$LINUX_TARGET \
	\
        --prefix=/ \
	--with-sysroot=$PREFIX/$LINUX_TARGET \
	\
	--enable-multilib \
	\

# Build libc (musl)
mkdir -p $SRC_DIR/build-musl
cd $SRC_DIR/build-musl
make -j$CPU_COUNT
make DESTDIR=$PREFIX install

# ============================================================

$PREFIX/bin/$METAL_TARGET-gcc --version
$PREFIX/bin/$LINUX_TARGET-gcc --version

echo $($PREFIX/bin/$LINUX_TARGET-gcc --version 2>&1 | head -1 | sed -e"s/$LINUX_TARGET-gcc (GCC) //")
