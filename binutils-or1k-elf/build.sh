mkdir build
cd build
../configure \
  --target=or1k-elf \
  --prefix=$PREFIX \
  --enable-deterministic-archives \

make -j$CPU_COUNT
make install-strip
TZ=UTC date +%Y%m%d_%H%M%S > ../__conda_buildstr__.txt
