#!/bin/bash

set -e
set -x

#Currently verilator-uhdm assumes that Surelog/UHDM is installed in '../image/' folder
#This fixes CXXFLAGS/LDFLAGS, when proper flag will be added to verilator,
#This can be removed
export CXXFLAGS="$CXXFLAGS -I$PREFIX/include/uhdm -I$PREFIX/include/uhdm/include -I$PREFIX/include/uhdm/headers"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -L$PREFIX/lib/uhdm"

make -C Surelog release install -j$CPU_COUNT
autoconf && ./configure --prefix=$PREFIX && make -j$CPU_COUNT && make install

sed -i 's/"verilator_bin"/"verilator_bin-uhdm"/g' $PREFIX/bin/verilator
sed -i 's/"verilator_bin_dbg"/"verilator_bin_dbg-uhdm"/g' $PREFIX/bin/verilator

mv "$PREFIX/bin/verilator" "$PREFIX/bin/verilator-uhdm"
mv "$PREFIX/bin/verilator_bin" "$PREFIX/bin/verilator_bin-uhdm"
mv "$PREFIX/bin/verilator_bin_dbg" "$PREFIX/bin/verilator_bin_dbg-uhdm"
