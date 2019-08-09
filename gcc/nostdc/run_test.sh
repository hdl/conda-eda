#!/bin/bash

# no C library gcc run test

set +x
set +e

TARGET=${TOOLCHAIN_ARCH}-elf
GCC=$TARGET-gcc
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

echo "Compile and link a 'bare metal' binary"

cat > main.c <<EOF
int main() {
	volatile int i = 0;
	for (; i < 0; i++);
	return 0;
}
EOF

echo "Compiling main"
$GCC -v -c main.c -o main.o
SUCCESS=$?
if [ $SUCCESS -ne 0 ]; then
	echo "Compiler didn't exit successfully."
	exit 1
fi

if [ ! -e main.o ]; then
	echo "Compiler didn't make a binary output file!"
	exit 1
fi

echo "Info about main.o"
file main.o
$TARGET-objdump -f ./main.o

$TARGET-objdump -f ./main.o
if ! $TARGET-objdump -f ./main.o | grep -q "architecture: ${ELF_ARCH}"; then
	echo "Compiled binary output not correct architecture!"
	exit 1
fi

echo "Linking main.elf"
cat > main.ld <<EOF
SECTIONS
{
  . = 0x10000;
  .text : { *(.text) }
  . = 0x80000;
  .data : { *(.data) }
  .bss : { *(.bss) }
}
EOF

$TARGET-ld -T main.ld -o ./main.elf main.o -M
SUCCESS=$?
if [ $SUCCESS -ne 0 ]; then
	echo "Linker didn't exit successfully."
	exit 1
fi

echo "Info about main.elf"
file main.elf
$TARGET-objdump -f ./main.elf

echo "==========================================="

echo "Making sure we don't have any libc available"

cat > stdio1.c <<EOF
#include <stdio.h>
int main() {
	puts("Hello world\n");
	return 0;
}
EOF

echo "Compiling stdio1 (should fail!)"
$GCC -c stdio1.c -o stdio1.o
SUCCESS=$?
if [ $SUCCESS -eq 0 ]; then
	echo "Compiler has standard library!"
	exit 1
fi

echo "==========================================="

echo "Don't include the header and try to link.."
cat > stdio2.c <<EOF
int main() {
	puts("Hello world\n");
	return 0;
}
EOF

echo "Compiling stdio2"
$GCC -c stdio2.c -o stdio2.o -Wno-implicit-function-declaration
SUCCESS=$?
if [ $SUCCESS -ne 0 ]; then
	echo "Compiler wasn't able to compile stdio2.c"
	exit 1
fi

echo "Trying to link stdio2 (should fail!)"
cat > stdio2.ld <<EOF
SECTIONS
{
  . = 0x10000;
  .text : { *(.text) }
  . = 0x80000;
  .data : { *(.data) }
  .bss : { *(.bss) }
}
EOF
$TARGET-ld -T stdio2.ld -o ./stdio2.elf stdio2.o
SUCCESS=$?
if [ $SUCCESS -eq 0 ]; then
	echo "Linker was able to find puts!"
	exit 1
fi
