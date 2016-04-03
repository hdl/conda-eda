# Instructions from http://openrisc.io/newlib/building.html
GIT_REV=$(git describe --always)

mkdir build
cd build
../configure \
  --target=or1k-elf \
  --prefix=$PREFIX \
  --enable-deterministic-archives \
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
  --disable-libgloss

make -j$CPU_COUNT
make install
cd binutils
make install-strip

$PREFIX/bin/or1k-elf-ar --version 2>&1 | head -1 | sed -e's/.* //' -e"s/\$/_$GIT_REV/" > ../__conda_version__.txt
TZ=UTC date +%Y%m%d_%H%M%S > ../__conda_buildstr__.txt
