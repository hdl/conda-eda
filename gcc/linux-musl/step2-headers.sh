#!/bin/bash

set -e
set -x

# Install Linux Headers + C library headers
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
make headers_install ARCH=$LINUX_ARCH INSTALL_HDR_PATH=$SYSROOT/include

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
#        CT_DoLog EXTRA "Installing C library headers"
#        CT_DoExecLog ALL make DESTDIR="${multi_root}" install-headers
make install-headers
#        CT_DoLog EXTRA "Building C library start files"
#        CT_DoExecLog ALL make DESTDIR="${multi_root}" \
#            obj/crt/crt1.o obj/crt/crti.o obj/crt/crtn.o
#        CT_DoLog EXTRA "Installing C library start files"
#        CT_DoExecLog ALL cp -av obj/crt/crt*.o "${multi_root}${multilib_dir}"
make obj/crt/crt1.o obj/crt/crti.o obj/crt/crtn.o
mkdir -p "$SYSROOT/lib"
cp -av obj/crt/crt*.o "$SYSROOT/lib"

#        CT_DoExecLog ALL ${CT_TARGET}-${CT_CC} -nostdlib \
#            -nostartfiles -shared -x c /dev/null -o "${multi_root}${multilib_dir}/libc.so"
$LINUX_TARGET-gcc -nostdlib \
    -nostartfiles -shared -x c /dev/null -o "$SYSROOT/lib/libc.so"

echo
echo
echo "--------------------------------------------"
find $SYSROOT | sort
echo "--------------------------------------------"
echo
echo
ls -l $SYSROOT/include/linux/fcntl.h
ls -l $SYSROOT/include/stdio.h
ls -l $SYSROOT/lib/libc.so
