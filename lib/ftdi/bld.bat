mkdir build
cd build
REM Configure step

python -c "print(r'%PREFIX%'.replace('\\','/'))" > temp.txt
set /p BASH_PREFIX=<temp.txt
python -c "print(r'%BUILD_PREFIX%'.replace('\\','/'))" > temp.txt
set /p BASH_BUILD_PREFIX=<temp.txt

set MINGW=%MINGW64%
set PATH=%MINGW%;%PATH%

cmake ^
	-G "MinGW Makefiles"^
	-DCMAKE_C_FLAGS=-L%BASH_PREFIX%/lib -lusb-1.0^
	-DCMAKE_INSTALL_PREFIX="%BASH_PREFIX%/Library"^
	-DCMAKE_SH="CMAKE_SH-NOTFOUND"^
	-DCMAKE_PREFIX_PATH="%BASH_PREFIX%/Library"^
	-Wno-dev ^
	../  || exit 1

cmake --build . || exit 1
cmake --build . --target install || exit 1

