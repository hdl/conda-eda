#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

echo "============================================================"
echo "CFLAGS='$CFLAGS'"
echo "CXXFLAGS='$CXXFLAGS'"
echo "CPPFLAGS='$CPPFLAGS'"
echo "DEBUG_CXXFLAGS='$DEBUG_CXXFLAGS'"
echo "DEBUG_CPPFLAGS='$DEBUG_CPPFLAGS'"
echo "LDFLAGS='$LDFLAGS'"
echo "------------------------------------------------------------"
# -Wundef causes warnings on undefined preprocessor defines (e.g. o
# tbb_config.h:56:7: warning: "__GLIBCPP__" is not defined, evaluates to 0 [-Wundef]
# elif __GLIBCPP__ || __GLIBCXX__
export CFLAGS="$(echo $CFLAGS | sed -e's/-Wundef //') -w"
export CXXFLAGS="$(echo $CXXFLAGS | sed -e's/-Wundef //') -w"
export CPPFLAGS="$(echo $CPPFLAGS | sed -e's/-Wundef //')"
export DEBUG_CXXFLAGS="$(echo $DEBUG_CXXFLAGS | sed -e's/-Wundef //') -w"
export DEBUG_CPPFLAGS="$(echo $DEBUG_CPPFLAGS | sed -e's/-Wundef //')"
echo "CFLAGS='$CFLAGS'"
echo "CXXFLAGS='$CXXFLAGS'"
echo "CPPFLAGS='$CPPFLAGS'"
echo "DEBUG_CXXFLAGS='$DEBUG_CXXFLAGS'"
echo "DEBUG_CPPFLAGS='$DEBUG_CPPFLAGS'"
echo "LDFLAGS='$LDFLAGS'"
env
export M4=${PREFIX}/bin/m4
mkdir build
cd build
# ODIN and ABC are disabled to keep build time less than Travis CI timeout.
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DWITH_ODIN=OFF \
    -DWITH_ABC=OFF \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    ..
grep -i flags CMakeCache.txt
make -k -j$CPU_COUNT || make VERBOSE=1
make test
make -j$CPU_COUNT install

mkdir -p ${PREFIX}/lib
mv ${PREFIX}/bin/*.a ${PREFIX}/lib/
