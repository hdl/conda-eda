#! /bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

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
gcc -Wall -Wstrict-prototypes -Wformat-security -Wshadow -Wextra -Wno-unused-parameter -Wbad-function-cast -Wcast-align -Wredundant-decls -Werror -g -O2 -o src/openocd src/main.o -Wl,-Bstatic src/.libs/libopenocd.a ./jimtcl/libjim.a -lusb-1.0 -lusb -lftdi -Wl,-Bdynamic -Wl,--no-whole-archive -ludev -lpthread -ldl -lm
ldd ./src/openocd
ls -l ./src/openocd
du -h ./src/openocd
echo "---------------------------"
strip ./src/openocd
ls -l ./src/openocd
du -h ./src/openocd

make install
