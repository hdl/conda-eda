@echo on

set CPU_COUNT=2
python -c "print(r'%PREFIX%'.replace('\\','/'))" > temp.txt
set /p BASH_PREFIX=<temp.txt
del temp.txt

set GCC_ARCH=x86_64-w64-mingw32
set CXX=%GCC_ARCH%-g++
set CC=%GCC_ARCH%-gcc
set INCLUDE_DIR=%BASH_PREFIX%/Library/include
set LIBRARY_DIR=%BASH_PREFIX%/Library/lib
echo PREFIX := %BASH_PREFIX%>Makefile.conf
sed -i 's/^    /\t/g' fasm-plugin/Makefile
sed -i 's/^    /\t/g' xdc-plugin/Makefile

make -C fasm-plugin install
make -C xdc-plugin install
