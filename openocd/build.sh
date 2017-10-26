#!/bin/bash

set -x
set -e
#export GIT_AUTHOR_NAME="Conda Build"
#export GIT_AUTHOR_EMAIL="robot@timvideos.us"
#export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
#export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
#git commit -a -m "Changes for conda."

git status

./bootstrap
mkdir build
cd build
../configure \
  --prefix=$PREFIX \
  --enable-static \
  --disable-shared \
  --enable-usb-blaster-2 \
  --enable-usb_blaster_libftdi \
  --enable-jtag_vpi \
  --enable-remote-bitbang \


make -j$CPU_COUNT

echo "---------------------------"
ldd ./src/openocd
ls -l ./src/openocd
du -h ./src/openocd
echo "---------------------------"
gcc -Wall -Wstrict-prototypes -Wformat-security -Wshadow -Wextra -Wno-unused-parameter -Wbad-function-cast -Wcast-align -Wredundant-decls -Werror -g -O2 -o src/openocd src/main.o -Wl,-Bstatic src/.libs/libopenocd.a ./jimtcl/libjim.a -lusb-1.0 -lusb -lftdi1 -lftdi -Wl,-Bdynamic -Wl,--no-whole-archive -ludev -lpthread -ldl -lm
ldd ./src/openocd
ls -l ./src/openocd
du -h ./src/openocd
echo "---------------------------"
strip ./src/openocd
ls -l ./src/openocd
du -h ./src/openocd

make install

./src/openocd --version
./src/openocd --version 2>&1 | head -1 | sed -e's/+dev-[0]\+/_/' -e's/-/_/g' -e's/.* 0\./0./' -e's/ .*//' -e's/_dirty//' > ../__conda_version__.txt
./src/openocd --version 2>&1 | head -1 | sed -e's/[^(]*(//' -e's/)//' -e's/://g' -e's/-//g' -es'/[0-9][0-9][0-9][0-9]$/_\0/' > ../__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S > ../__conda_buildnum__.txt
