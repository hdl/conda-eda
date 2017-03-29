#!/bin/bash

# lm32 gcc newlib run test

set +x
set +e

TARGET=lm32-elf
GCC=$TARGET-newlib-gcc
OBJDUMP=$TARGET-objdump


# Check the compiler version matches
GCC_PKG_VERSION=$(echo $PKG_VERSION | sed -e's/-.*//')
GCC_RUN_VERSION=$($GCC --version 2>&1 | head -1 | sed -e"s/$GCC (GCC) //")

if [ "$GCC_PKG_VERSION" != "$GCC_RUN_VERSION" ]; then
	echo
	echo "  package version: $GCC_PKG_VERSION ($($PKG_VERSION))"
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

echo "Compile and link a 'bare metal' binary with stdlib"

cat > main.c <<EOF
#include <stdio.h>

int main() {
	puts("Hello world!\n");
}
EOF

$GCC -g main.c -o main -Wl,-Map=output.map
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
cat output.map

$TARGET-objdump -f ./main
if ! $TARGET-objdump -f ./main | grep -q 'architecture: lm32'; then
	echo "Compiled binary output not correct architecture!"
	exit 1
fi

$TARGET-objdump -g ./main | grep DW_AT_name | grep newlib
if ! $TARGET-objdump -g ./main | grep DW_AT_name | grep newlib; then
	echo "Compiled binary not linked against newlib!"
	exit 1
fi
