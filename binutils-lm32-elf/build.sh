mkdir build
cd build
../configure --target=lm32-elf --prefix=$PREFIX --enable-deterministic-archives
make -j$CPU_COUNT
make install-strip
