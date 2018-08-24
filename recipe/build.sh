./configure --prefix="$PREFIX" --with-gmp-prefix="$PREFIX"
make
make check
make install-strip
