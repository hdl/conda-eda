#!/bin/bash
#****************************************************************************
#* build.sh
#* 
#* Conda package build script for SymbiYosys and supporting solvers
#****************************************************************************

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

cwd=`pwd`
CFLAGS_ORIG=${CFLAGS}

#********************************************************************
#* Build Boolector
#********************************************************************

unset CFLAGS

cd ${cwd}/boolector

echo "CFLAGS=${CFLAGS}"
./contrib/setup-btor2tools.sh
if test $? -ne 0; then exit 1; fi

./contrib/setup-lingeling.sh
if test $? -ne 0; then exit 1; fi

echo "CFLAGS=${CFLAGS}"
./configure.sh --prefix ${PREFIX}
if test $? -ne 0; then exit 1; fi

cd build

make -j${CPU_COUNT}
if test $? -ne 0; then exit 1; fi

make install
if test $? -ne 0; then exit 1; fi

CFLAGS=${CFLAGS_ORIG}

#********************************************************************
#* Build Z3
#********************************************************************

cd ${cwd}/z3
python scripts/mk_make.py
if test $? -ne 0; then exit 1; fi

cd build

make -j${CPU_COUNT}
if test $? -ne 0; then exit 1; fi

make PREFIX=${PREFIX} install
if test $? -ne 0; then exit 1; fi

#********************************************************************
#* Build Yices2
#* Note: disabled due to issues finding libgmp
#********************************************************************
#cd ${cwd}
#
#git clone https://github.com/SRI-CSL/yices2.git yices2
#if test $? -ne 0; then exit 1; fi
#
#cd yices2
#autoconf
#if test $? -ne 0; then exit 1; fi
#
#./configure --prefix=${PREFIX}
#if test $? -ne 0; then exit 1; fi
#
#make -j${CPU_COUNT}
#if test $? -ne 0; then exit 1; fi
#
#make install
#if test $? -ne 0; then exit 1; fi

#********************************************************************
#* Build SymbiYosys
#********************************************************************
cd ${cwd}/SymbiYosys
make -j$CPU_COUNT
make PREFIX=${PREFIX} install


