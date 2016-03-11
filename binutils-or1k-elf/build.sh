# Instructions from http://openrisc.io/newlib/building.html
GIT_REV=$(git describe --always)

mkdir build
cd build
../configure \
  --target=or1k-elf \
  --prefix=$PREFIX \
  --enable-shared \
  --disable-itcl \
  --disable-tk \
  --disable-tcl \
  --disable-winsup \
  --disable-gdbtk \
  --disable-libgui \
  --disable-rda \
  --disable-sid \
  --disable-sim \
  --disable-gdb \
  --with-sysroot \
  --disable-newlib \
  --disable-libgloss \
  --with-system-zlib
make -j4
make install

$PREFIX/bin/or1k-elf-ar --version 2>&1 | head -1 | sed -e's/.* //' -e"s/\$/_$GIT_REV/" > ../__conda_version__.txt
TZ=UTC date +%Y%m%d_%H%M%S > ../__conda_buildstr__.txt
