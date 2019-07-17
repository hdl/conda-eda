if [[ "`uname`" == "Linux" ]]
then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${PREFIX}/lib"
fi

./configure --prefix="$PREFIX" --with-gmp-prefix="$PREFIX"
make -j$CPU_COUNT
make check
make install-strip
