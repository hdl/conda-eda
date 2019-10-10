#! /bin/bash

set -e
set -x

if [ x"$TRAVIS" = xtrue ]; then
	CPU_COUNT=2
fi

for f in libserialport libsigrok libsigrokdecode sigrok-cli
do
	cd $f
	./autogen.sh
	./configure --prefix=$PREFIX
	make -j$CPU_COUNT
	make install
	cd -
done

$PREFIX/bin/sigrok-cli -V
find $PREFIX/share -name "__pycache__" -exec rm -rv {} +
