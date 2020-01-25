@echo on

REM gcc requires path with slashes not backslashes
python -c "print(r'%PREFIX%'.replace('\\','/'))" > temp.txt
set /p BASH_PREFIX=<temp.txt
python -c "print(r'%BUILD_PREFIX%'.replace('\\','/'))" > temp.txt
set /p BASH_BUILD_PREFIX=<temp.txt
del temp.txt

make CC="x86_64-w64-mingw32-gcc -I%BASH_BUILD_PREFIX%/Library/include/libftdi1/ -L%BASH_BUILD_PREFIX%/Library/lib" SUBDIRS="iceprog" PREFIX=%BASH_PREFIX%
if errorlevel 1 exit 1
mkdir %PREFIX%\bin
cp iceprog/iceprog.exe %BASH_PREFIX%/bin/
if errorlevel 1 exit 1
