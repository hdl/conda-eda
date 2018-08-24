set AR=llvm-ar
set LD=lld-link
set CXX=clang++
set CC=clang
set ac_cv_have_decl__BitScanForward=yes

FOR /F "delims=" %%i IN ('cygpath.exe -u "%PREFIX%"') DO set "PREFIX=%%i"
bash -lc "./configure --with-int=imath CFLAGS='-O3 -Dstrdup=_strdup'"
bash -lc "make"
bash -lc "make check"
bash -lc "make install-strip"
