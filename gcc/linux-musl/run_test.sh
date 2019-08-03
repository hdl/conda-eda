#!/bin/bash

# gcc linux-musl run test

TARGET=${TOOLCHAIN_ARCH}-linux-musl
GCC=$TARGET-gcc
OBJDUMP=$TARGET-objdump

set -x
set -e

echo "============================="
echo "============================="
echo "============================="
echo "============================="
$GCC --help || true
echo "-----"
$GCC --version || true
echo "-----"
$GCC -dumpspecs || true
echo "-----"
$GCC -dumpversion || true
echo "-----"
$GCC -dumpmachine || true
echo "-----"
$GCC -print-search-dirs || true
echo "-----"
$GCC -print-libgcc-file-name || true
echo "-----"
$GCC -print-file-name=m || true
echo "-----"
$GCC -print-prog-name=as || true
echo "-----"
$GCC -print-multiarch || true
echo "-----"
$GCC -print-multi-directory || true
echo "-----"
$GCC -print-multi-lib || true
echo "-----"
$GCC -print-multi-os-directory || true
echo "-----"
$GCC -print-sysroot || true
echo "-----"
$GCC -print-sysroot-headers-suffix || true
echo "============================="
echo "============================="
echo "============================="
echo "============================="

set +x
set +e


case "${TOOLCHAIN_ARCH}" in
riscv32)
	ELF_ARCH="riscv:rv32"
	;;
sh)
	ELF_ARCH="sh"
	;;
or1k)
	ELF_ARCH="or1k"
	;;
lm32)
	ELF_ARCH="lm32"
	;;
*)
	echo "Unknown architecture! ${TOOLCHAIN_ARCH}"
	exit 1
	;;
esac

# Check the compiler version matches
GCC_PKG_VERSION=$(echo $PKG_VERSION | sed -e's/-.*//')
GCC_RUN_VERSION=$($GCC --version 2>&1 | head -1 | sed -e"s/$GCC (//" -e"s/).*//")

if [ "$GCC_PKG_VERSION" != "$GCC_RUN_VERSION" ]; then
	echo
	echo "  package version: $GCC_PKG_VERSION ($PKG_VERSION)"
	echo "installed version: $GCC_RUN_VERSION ($($GCC --version 2>&1 | head -1))"
	echo
	echo "Compiler doesn't have correct version!"
	echo
 	exit 1
fi

# Check the compiler was build for the right machine
GCC_TARGET=$($GCC -dumpmachine)
if [ "$GCC_TARGET" != "$TARGET" ]; then
	echo
	echo "  package target: $TARGET"
	echo "installed target: $GCC_TARGET"
	echo
	echo "Compiler doesn't have correct target!"
	echo
 	exit 1
fi

# Check the compiler can build a simple C app which requires the standard
# library.
echo "==========================================="
set -x
$GCC -v --version
$GCC -v --target-help
$GCC -v -dumpspecs
$GCC -v -dumpversion
$GCC -v -dumpmachine
$GCC -v -print-search-dirs
$GCC -v -print-libgcc-file-name
$GCC -v -print-multiarch
$GCC -v -print-multi-directory
$GCC -v -print-multi-lib
$GCC -v -print-multi-os-directory
$GCC -v -print-sysroot
$GCC -print-sysroot-headers-suffix
#$TARGET-cpp -Wp,-v
echo "==========================================="

echo "Compile and link a 'bare metal' binary with stdlib"

cat > main.c <<EOF
#include <stdio.h>

int main() {
	puts("Hello world!\n");
}
EOF

echo "Compiling main"
$GCC -v -g main.c -o main -Wl,-Map=output.map
SUCCESS=$?
if [ $SUCCESS -ne 0 ]; then
	echo "Compiler didn't exit successfully."
	exit 1
fi

if [ ! -e main ]; then
	echo "Compiler didn't make a binary output file!"
	exit 1
fi

file main
echo
echo "output.map"
echo "-------------------------------------------"
cat output.map \
	| sed -e's-[^ ]\+/bin/-[BIN]/-g' -e's-[^ ]\+/work/-[WORK]/-g'
echo "-------------------------------------------"
echo

$TARGET-objdump -f ./main
if ! $TARGET-objdump -f ./main | grep -q "architecture: ${ELF_ARCH}"; then
	echo "Compiled binary output not correct architecture!"
	exit 1
fi

$TARGET-objdump -g ./main 2>&1 \
	| grep libc \
	| sed -e's-[^ ]\+/bin/-[BIN]/-g' -e's-[^ ]\+/work/-[WORK]/-g'
SUCCESS=$?
if [ $SUCCESS -ne 0 ]; then
	echo "Compiled binary not linked against musl libc!"
	exit 1
fi
