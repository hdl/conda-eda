set AR=llvm-ar
set LD=lld-link
set CXX=clang++
set CC=clang
set ac_cv_have_decl__BitScanForward=yes

FOR /F "delims=" %%i IN ('cygpath.exe -u "%PREFIX%"') DO set "PREFIX=%%i"
bash -lc "cd $SRC_DIR &&  ./configure --with-int=imath CFLAGS='-O3 -Dstrdup=_strdup' --prefix=$PREFIX/Library"
bash -lc "cd $SRC_DIR && make -j$CPU_COUNT"
bash -lc "cd $SRC_DIR && make check"
bash -lc "cd $SRC_DIR && make install-strip"

rm "%LIBRARY_LIB%/libisl.la"
mv "%LIBRARY_LIB%/libisl.a" "%LIBRARY_LIB%/isl.lib"
