#!/bin/bash

# gcc newlib run test

set +x
set +e

TARGET=${TOOLCHAIN_ARCH}-elf
GCC=$TARGET-newlib-gcc
OBJDUMP=$TARGET-objdump

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
$GCC --version
$GCC --target-help
$GCC -dumpspecs
$GCC -dumpversion
$GCC -dumpmachine
$GCC -print-search-dirs
$GCC -print-libgcc-file-name
$GCC -print-multiarch
$GCC -print-multi-directory
$GCC -print-multi-lib
$GCC -print-multi-os-directory
$GCC -print-sysroot
find $($GCC -print-sysroot)
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
	| grep DW_AT_name \
	| grep newlib \
	| sed -e's-[^ ]\+/bin/-[BIN]/-g' -e's-[^ ]\+/work/-[WORK]/-g'
SUCCESS=$?
if [ $SUCCESS -ne 0 ]; then
	echo "Compiled binary not linked against newlib!"
	exit 1
fi
