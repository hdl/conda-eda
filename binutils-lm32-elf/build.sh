mkdir build
cd build
../configure --target=lm32-elf --prefix=$PREFIX
make -j4
make install
