# Instructions from http://openrisc.io/newlib/building.html

# Fetch upstream binutils-gdb so we can get a git-describe delta
git remote add upstream git://sourceware.org/git/binutils-gdb.git
git fetch upstream

# Find our current or1k release
GDB_RELEASE=$(git describe --abbrev=0 --match gdb-*-or1k-release | sed -e's/^gdb-//' -e's/-or1k-release$//')
# Find our relationship to the upstream gdb release
GIT_REV=$(git describe --always --long --match gdb-${GDB_RELEASE}-release | sed -e"s/^gdb-${GDB_RELEASE}-release-//" -e's/-/_/')

(
mkdir build
cd build
../configure \
  --target=or1k-elf \
  --prefix=$PREFIX \
 \
  --disable-itcl \
  --disable-tk \
  --disable-tcl \
  --disable-winsup \
  --disable-gdbtk \
  --disable-libgui \
  --disable-rda \
  --disable-sid \
  --disable-sim \
  --disable-or1ksim \
  --with-sysroot \
  --disable-newlib \
  --disable-libgloss \
  --disable-gas \
  --disable-ld \
  --disable-binutils \
  --disable-gprof \
  --with-system-zlib \
 \
  --disable-shared \
  --enable-static \

make -j$CPU_COUNT
make install
)

$PREFIX/bin/or1k-elf-gdb --version
$PREFIX/bin/or1k-elf-gdb --version 2>&1 | head -1 | sed -e's/.* //' -e"s/\$/_$GIT_REV/" > ./__conda_version__.txt
TZ=UTC date +%Y%m%d_%H%M%S > ./__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S > ./__conda_buildnum__.txt
