./configure --prefix="$PREFIX" --with-gmp-prefix="$PREFIX"
make -j$CPU_COUNT
make check
make install-strip
