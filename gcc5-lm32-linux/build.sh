#!/bin/bash

rm -rf libstdc++-v3

if [ "$(uname)" == "Darwin" ]; then
    export DYLD_LIBRARY_PATH="$PREFIX/lib/"
    export LDFLAGS="-Wl,-headerpad_max_install_names"
    export BOOT_LDFLAGS="-Wl,-headerpad_max_install_names"

    ./configure \
        --prefix="$PREFIX" \
        --libdir="$PREFIX/lib" \
        --with-gmp="$PREFIX" \
        --with-mpfr="$PREFIX" \
        --with-mpc="$PREFIX" \
        --with-isl="$PREFIX" \
        --with-cloog="$PREFIX" \
        --with-boot-ldflags="$LDFLAGS" \
        --with-stage1-ldflags="$LDFLAGS" \
        --enable-checking=release \
        --disable-multilib \
	--target=lm32-elf \
	--enable-languages="c,c++" \
	--disable-libgcc \
	--disable-libssp
else
    # For reference during post-link.sh, record some
    # details about the OS this binary was produced with.
    mkdir -p "${PREFIX}/share"
    cat /etc/*-release > "${PREFIX}/share/conda-gcc-build-machine-os-details"
    ./configure \
        --prefix="$PREFIX" \
        --libdir="$PREFIX/lib" \
        --with-gmp="$PREFIX" \
        --with-mpfr="$PREFIX" \
        --with-mpc="$PREFIX" \
        --with-isl="$PREFIX" \
        --with-cloog="$PREFIX" \
        --enable-checking=release \
        --disable-multilib \
	--target=lm32-elf \
	--enable-languages="c,c++" \
	--disable-libgcc \
	--disable-libssp
fi
make -j"$CPU_COUNT"
make install-strip
