#! /bin/bash

set -e
set -x

export CC_FOR_BUILD=$CC

echo "TEST LIBREADLINE"
$CC rltest.c -lreadline || true
echo "TEST LIBREADLINE"

sh ./autoconf.sh
./configure --prefix=$PREFIX || true

cat config.log
cat configure

make -j$CPU_COUNT
make install

$PREFIX/bin/iverilog -V
$PREFIX/bin/iverilog -h || true
