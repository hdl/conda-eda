@echo on

sed -i "s/-ggdb //;" config.mk
if errorlevel 1 exit 1
REM python3 is in python.exe on windows
sed -i "s/python3/python/;" icebox/Makefile
if errorlevel 1 exit 1
sed -i "s/python3/python/;" icetime/Makefile
if errorlevel 1 exit 1
make -j2 CXX="x86_64-w64-mingw32-g++" SUBDIRS="icebox icepack icemulti icepll icebram" STATIC=1
if errorlevel 1 exit 1

REM icetime fails when PREFIX contains backslashes
make -j2 CXX="x86_64-w64-mingw32-g++" SUBDIRS="icetime" STATIC=1 PREFIX=~/
if errorlevel 1 exit 1

mkdir %PREFIX%\bin
if errorlevel 1 exit 1
for %%G in (icepack,icemulti,icepll,icetime,icebram) DO (cp %%G\%%G %PREFIX%\bin )
if errorlevel 1 exit 1

mkdir %PREFIX%\share
if errorlevel 1 exit 1
mkdir %PREFIX%\share\icebox
if errorlevel 1 exit 1
cp icebox/chipdb*.txt %PREFIX%/share/icebox
if errorlevel 1 exit 1
cp icefuzz/timings*.txt %PREFIX%/share/icebox
if errorlevel 1 exit 1
