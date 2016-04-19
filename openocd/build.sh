#!/bin/bash

set -x
set -e
export GIT_AUTHOR_NAME="Conda Build"
export GIT_AUTHOR_EMAIL="robot@timvideos.us"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git commit -a -m "Changes for conda."

./bootstrap
mkdir build
cd build
../configure \
  --prefix=$PREFIX \
  --enable-usb-blaster-2 \
  --enable-usb_blaster_libftdi \
  --enable-jtag_vpi \

make -j$CPU_COUNT
make install

./src/openocd --version 2>&1 | head -1 | sed -e's/-/_/g' -e's/.* 0\./0./' -e's/ .*//' > ../__conda_version__.txt
./src/openocd --version 2>&1 | head -1 | sed -e's/[^(]*(//' -e's/)//' -e's/://g' -e's/-/_/g' > ../__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S > ../__conda_buildnum__.txt
