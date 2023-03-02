#! /bin/bash

set -e
set -x

cd $BUILD_PREFIX/bin
ln -s "$AR" ar
cd -

unset VERILATOR_ROOT
autoconf
./configure \
  --prefix=$PREFIX \

make -j$CPU_COUNT
make install

ls -la ${PREFIX}/share/verilator/include

# Fix hard coded paths in verilator
sed -i -e 's-/.*_build_env/bin/--' $PREFIX/share/verilator/include/verilated.mk
