#!/bin/bash

set -e

TARGET=or1k-elf

CONDA_PYTHON=$(conda info --root)/bin/python

# Check binutils
$TARGET-as --version

# Fetch upstream gcc so we can get a git-describe delta
echo $SRC_DIR
echo $PWD

(
	export GIT_DIR=$(${CONDA_PYTHON} ${RECIPE_DIR}/find-git-cache.py)
	git remote -v
	if !  git remote -v | grep -q upstream; then
		git remote add upstream git://gcc.gnu.org/git/gcc.git
	fi
	git fetch upstream
	git fetch upstream --tags
)

git fetch
git fetch --tags

set +x

# Find our current or1k release
OR1K_RELEASE=$(git describe --abbrev=0 --match or1k-*-*)
echo "    or1k release: '$OR1K_RELEASE'"
UPSTREAM_RELEASE=$(echo $OR1K_RELEASE | sed -e's/^or1k-/gcc-/' -e's/\./_/g' -e's/-[0-9]\+$/-release/')
echo "upstream release: '$UPSTREAM_RELEASE'"
GIT_REV=$(git describe --tags --long --match ${UPSTREAM_RELEASE} | sed -e"s/^${UPSTREAM_RELEASE}-//" -e's/-/_/')
echo "  or1k git delta: '$GIT_REV'"

set -x

echo $PWD
rm -rf libstdc++-v3
cd ..
ls -l

mkdir -p build-gcc
cd build-gcc

# --without-headers - Tells GCC not to rely on any C library (standard or runtime) being present for the target.
export LDFLAGS=-static
$SRC_DIR/configure \
        --prefix=$PREFIX \
        --with-gmp=$PREFIX \
        --with-mpfr=$PREFIX \
        --with-mpc=$PREFIX \
        --with-isl=$PREFIX \
        --with-cloog=$PREFIX \
	\
	--target=$TARGET \
	--without-headers \
	--enable-languages="c" \
	--enable-threads=single \
	\
	--disable-libatomic \
	--disable-libgcc \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-libquadmath \
	--disable-libssp \
	--disable-multilib \
	--disable-nls \
	--disable-shared \
	--disable-tls \
	\


make -j$CPU_COUNT
make install-strip
cd ..

$PREFIX/bin/$TARGET-gcc --version
$PREFIX/bin/$TARGET-gcc --version 2>&1 | head -1 | sed -e"s/$TARGET-gcc (GCC) //" -e"s/\$/_$GIT_REV/" > $SRC_DIR/__conda_version__.txt
touch .buildstamp
TZ=UTC date +%Y%m%d_%H%M%S -r .buildstamp > $SRC_DIR/__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S  -r .buildstamp > $SRC_DIR/__conda_buildnum__.txt
cat $SRC_DIR/__conda_*__.txt
