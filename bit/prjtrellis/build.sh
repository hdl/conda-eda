#!/bin/bash

set -e
set -x

# Use 'Python3_FIND_STRATEGY=LOCATION' in projects with 'cmake_minimum_required'
# <3.15 too. More info: https://cmake.org/cmake/help/v3.22/policy/CMP0094.html
#
# The 'CMAKE_ARGS' variable contains arguments recommended for building by Conda.
CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_POLICY_DEFAULT_CMP0094=NEW"

mkdir -p libtrellis/build
cd libtrellis/build

cmake \
	${CMAKE_ARGS} \
	\
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
	-DBOOST_ROOT="${BUILD_PREFIX}" \
	-DBoost_NO_SYSTEM_PATHS:BOOL=ON \
	-DBOOST_INCLUDEDIR="${BUILD_PREFIX}/include" \
	-DBOOST_LIBRARYDIR="${BUILD_PREFIX}/lib" \
	-DBUILD_PYTHON=ON \
	-DBUILD_SHARED=ON \
	-DSTATIC_BUILD=OFF \
	-DBoost_USE_STATIC_LIBS=ON \
	..

make -j$CPU_COUNT
make DESTDIR=${PREFIX} install
