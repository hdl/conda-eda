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

LINUX_TARGET=${TOOLCHAIN_ARCH}-linux-musl

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

SYSROOT=$PREFIX/$TARGET/sysroot
mkdir -p $SYSROOT/usr/include

# ============================================================

(
	# Stage 1 GCC
	export CFLAGS="$CFLAGS -O0 -g0"
	export CXXFLAGS="$CXXFLAGS -O0 -g0"

	mkdir -p $SRC_DIR/build-gcc1
	cd $SRC_DIR/build-gcc1
	$SRC_DIR/gcc1/configure \
		\
		--prefix=/ \
		--with-sysroot=$SYSROOT \
		\
		--target=$LINUX_TARGET \
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

	# Build GCC
	mkdir -p $SRC_DIR/build-gcc1
	cd $SRC_DIR/build-gcc1

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
)

# ============================================================

(
	# Install C library
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

	# Linux Headers
	case "${TOOLCHAIN_ARCH}" in
		riscv*)	LINUX_ARCH=riscv 	;;
		or1k*)	LINUX_ARCH=openrisc	;;
		sh*)	LINUX_ARCH=sh		;;
	esac
	export LINUX_ARCH

	cd $SRC_DIR/kernel-headers
	make defconfig ARCH=$LINUX_ARCH
	make headers_install ARCH=$LINUX_ARCH INSTALL_HDR_PATH=$SYSROOT/usr/include
	find $SYSROOT | sort
	ls -ld $SYSROOT/include
	ls -ld $SYSROOT/usr/include

	# Configure musl
	mkdir -p $SRC_DIR/build-musl
	cd $SRC_DIR/build-musl
	$SRC_DIR/musl/configure \
		\
		--target=$LINUX_TARGET \
		\
		--prefix=/ \
		--with-sysroot=$SYSROOT \
		\
		--enable-multilib \
		\

	# Build libc (musl)
	mkdir -p $SRC_DIR/build-musl
	cd $SRC_DIR/build-musl
	make -j$CPU_COUNT
	make DESTDIR=$PREFIX install

)

# ============================================================

(
	# Stage 2 GCC
	mkdir -p $SRC_DIR/build-gcc2
	cd $SRC_DIR/build-gcc2

	# Configure GCC
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
	mkdir -p $SRC_DIR/build-gcc2
	cd $SRC_DIR/build-gcc2

	make -j$CPU_COUNT
	make DESTDIR=${PREFIX} install-strip
)

# Check GCC
echo -n "---?"
which $LINUX_TARGET-gcc
ls -l $(which $LINUX_TARGET-gcc)
file $(which $LINUX_TARGET-gcc)
echo "---"
$LINUX_TARGET-gcc --version 2>&1
echo "---"


$PREFIX/bin/$METAL_TARGET-gcc --version
$PREFIX/bin/$LINUX_TARGET-gcc --version

echo $($PREFIX/bin/$LINUX_TARGET-gcc --version 2>&1 | head -1 | sed -e"s/$LINUX_TARGET-gcc (GCC) //")
