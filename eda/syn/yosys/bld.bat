ECHO on

set MSYSTEM=MINGW%ARCH%

set CC=%GCC_ARCH%-gcc
set CXX=%GCC_ARCH%-g++
set HOST_FLAGS=--host=%GCC_ARCH%
set ABC_USE_NO_READLINE=1 
set ABC_USE_NO_PTHREADS=1 
set ABC_USE_LIBSTDCXX=1
set ABC_ARGS="LIBS=\"-static -lm\" OPTFLAGS=-O  ARCHFLAGS=\"-DSIZEOF_VOID_P=8 -DSIZEOF_LONG=4 -DNT64 -DSIZEOF_INT=4 -DWIN32_NO_DLL -DHAVE_STRUCT_TIMESPEC -D_POSIX_SOURCE \""

REM Check out if thats the correct revision of ABC prior to building yosys.
set ABCREV=623b5e8
set ABCPULL=1
set ABCURL=https://github.com/berkeley-abc/abc

git clone %ABCURL% abc
cd abc
git fetch origin master
git checkout %ABCREV%
if errorlevel 1 exit 1
cd ..

python -c "print(r'%PREFIX%'.replace('\\','/'))" > temp.txt
set /p BASH_PREFIX=<temp.txt
python -c "print(r'%BUILD_PREFIX%'.replace('\\','/'))" > temp.txt
set /p BASH_BUILD_PREFIX=<temp.txt
del temp.txt

sed -i "s/python3/python/;" techlibs/gowin/Makefile.inc

make config-msys2-64
if errorlevel 1 exit 1
set BISON_PKGDATADIR=%BASH_BUILD_PREFIX%/Library/usr/share/bison
mkdir tmp


make -j5^
     YOSYS_VER="$VER (Fomu build)" ^
     ABCREV=default ^
     LDLIBS="-static -lstdc++ -lm" ^
     ABCMKARGS=%ABC_ARGS% ^
     ENABLE_TCL=0 ^
     ENABLE_PLUGINS=0 ^
     ENABLE_READLINE=0 ^
     ENABLE_COVER=0 ^
     ENABLE_ZLIB=0 ^
     ENABLE_ABC=1 ^
	 PREFIX=%BASH_PREFIX%

if errorlevel 1 exit 1

mkdir %PREFIX%\bin
cp yosys.exe %PREFIX%\bin\yosys.exe
if errorlevel 1 exit 1
cp yosys-abc.exe %PREFIX%\bin\yosys-abc.exe
if errorlevel 1 exit 1
cp yosys-filterlib.exe %PREFIX%\bin\yosys-filterlib.exe
if errorlevel 1 exit 1
cp yosys-smtbmc %PREFIX%\bin\yosys-smtbmc
if errorlevel 1 exit 1
cp yosys-config %PREFIX%\bin\yosys-config
if errorlevel 1 exit 1
mkdir %PREFIX%\share
cp -r share/. %PREFIX%\share\yosys\.
if errorlevel 1 exit 1

find %BASH_PREFIX% -follow -type f -name '*.pyc' -delete
set PYTHONDONTWRITEBYTECODE=true

%PREFIX%\bin\yosys -V
%PREFIX%\bin\yosys-abc -v 2>&1 | find "compiled"
%PREFIX%\bin\yosys -Q -S tests/simple/always01.v
