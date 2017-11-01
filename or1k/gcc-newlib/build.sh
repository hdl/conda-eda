#!/bin/bash

# or1k gcc newlib build

set -e

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
	unset CFLAGS
	unset CXXFLAGS
	unset CPPFLAGS
	unset DEBUG_CXXFLAGS
	unset DEBUG_CPPFLAGS
	unset LDFLAGS
fi

TARGET=or1k-elf
GCC=$TARGET-newlib-gcc

CONDA_PYTHON=$(conda info --root)/bin/python
${CONDA_PYTHON} ${RECIPE_DIR}/download-extra-sources.py

set -x

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

# Check the "nostdc" gcc is already installed
GCC_STAGE1_VERSION=$($TARGET-gcc --version 2>&1 | head -1 | sed -e"s/$TARGET-gcc (GCC) //")
GCC_STAGE2_VERSION=$(echo $UPSTREAM_RELEASE | sed -e's/^gcc-//' -e's/_/./g' -e's/-.*//')
if [ "$GCC_STAGE1_VERSION" != "$GCC_STAGE2_VERSION" ]; then
	echo
	echo "nostdc version: $GCC_STAGE1_VERSION"
	echo "  this version: $GCC_STAGE2_VERSION"
	echo
	echo "Stage 1 compiler (nostdc) not the same version as us!"
	echo
 	exit 1
fi

set -x

echo $PWD
rm -rf libstdc++-v3
cd ..
ls -l

mkdir -p build-newlib
cd build-newlib
../newlib*/configure \
        --prefix=$PREFIX \
	--target=$TARGET \
	--disable-newlib-supplied-syscalls \

make -j$CPU_COUNT
make install
cd ..

mkdir -p build-gcc
cd build-gcc
export LDFLAGS=-static
$SRC_DIR/configure \
	\
	--program-prefix=$TARGET-newlib- \
	\
        --prefix=$PREFIX \
        --with-gmp=$PREFIX \
        --with-mpfr=$PREFIX \
        --with-mpc=$PREFIX \
        --with-isl=$PREFIX \
        --with-cloog=$PREFIX \
	\
	--target=$TARGET \
	--enable-languages="c,c++" \
	--with-newlib \
	--enable-libgcc \


make -j$CPU_COUNT
make install-strip

# Install aliases for the binutil tools
for BINUTIL in $(ls $PREFIX/bin/$TARGET-* | grep /$TARGET-); do
	NEWLIB_BINUTIL="$(echo $BINUTIL | sed -e"s_/$TARGET-_/$TARGET-newlib-_" -e's/newlib-newlib/newlib/')"

	if [ ! -e "$NEWLIB_BINUTIL" ]; then
		ln -sv "$BINUTIL" "$NEWLIB_BINUTIL"
	fi
done
ls -l $PREFIX/bin/$TARGET-newlib-*

cd ..

VERSION_DIR="$(echo $SRC_DIR | sed -e's-/work/.*-/work/-')"

$PREFIX/bin/$GCC --version
$PREFIX/bin/$GCC --version 2>&1 | head -1 | sed -e's/.* //' -e"s/\$/_$GIT_REV/" > $VERSION_DIR/__conda_version__.txt
touch .buildstamp
TZ=UTC date +%Y%m%d_%H%M%S -r .buildstamp > $VERSION_DIR/__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S  -r .buildstamp > $VERSION_DIR/__conda_buildnum__.txt
cat $VERSION_DIR/__conda_*__.txt
