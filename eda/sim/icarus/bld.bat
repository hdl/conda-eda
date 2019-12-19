ECHO ON

set MSYSTEM=MINGW%ARCH%
set GCC_ARCH=x86_64-w64-mingw32
set CC=%GCC_ARCH%-gcc
set CXX=%GCC_ARCH%-g++

REM gcc requires path with slashes not backslashes
python -c "print(r'%PREFIX%'.replace('\\','/'))" > temp.txt
set /p BASH_PREFIX=<temp.txt

bash -lc "ln -s ${LOCALAPPDATA}/Temp /tmp"
bash -lc "autoconf.sh" 
if errorlevel 1 exit 1
bash -lc "./configure --prefix=%BASH_PREFIX%"
if errorlevel 1 exit 1
bash -lc "make  -j4"
if errorlevel 1 exit 1
bash -lc "make install"
if errorlevel 1 exit 1



exit 0
