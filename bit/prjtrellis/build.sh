#!/bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

cd libtrellis
cmake \
	-DCMAKE_INSTALL_PREFIX=/ 			\
	-DCMAKE_INSTALL_BINDIR='/bin'			\
	-DCMAKE_INSTALL_DATADIR='/share'		\
	-DCMAKE_INSTALL_DATAROOTDIR='/share'		\
	-DCMAKE_INSTALL_DOCDIR='/share/doc'		\
	-DCMAKE_INSTALL_INCLUDEDIR='/include'		\
	-DCMAKE_INSTALL_INFODIR='/share/info'		\
	-DCMAKE_INSTALL_LIBDIR='/lib'			\
	-DCMAKE_INSTALL_LIBEXECDIR='/libexec'		\
	-DCMAKE_INSTALL_LOCALEDIR='/share/locale'	\
	\
	-DPYTHON_EXECUTABLE=$(which python) \
	-DPYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")  \
	-DPYTHON_LIBRARY=$(python -c "import distutils.sysconfig as sysconfig; print(sysconfig.get_config_var('LIBDIR'))") \
	\
	-DBOOST_INCLUDEDIR="${BUILD_PREFIX}/include" \
	.

make -j$CPU_COUNT
make DESTDIR=${PREFIX} install
