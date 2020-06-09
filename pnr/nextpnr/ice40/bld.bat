python -c "print(r'%PREFIX%'.replace('\\','/'))" > temp.txt
set /p BASH_PREFIX=<temp.txt
del temp.txt

REM Install boost with vcpkg
git clone --branch 2019.11 https://github.com/microsoft/vcpkg.git --single-branch
cd vcpkg
echo set(VCPKG_BUILD_TYPE release)>> triplets/x64-windows-static.cmake
powershell -Command "bootstrap-vcpkg.bat -disableMetrics"
if errorlevel 1 exit 1
vcpkg install boost-filesystem:x64-windows-static boost-program-options:x64-windows-static boost-thread:x64-windows-static boost-python:x64-windows-static boost-dll:x64-windows-static eigen3:x64-windows-static
if errorlevel 1 exit 1

cd ..

cmake -DBUILD_GUI=OFF -DARCH=ice40 -DICEBOX_ROOT="%BASH_PREFIX%/share/icebox" -DCMAKE_TOOLCHAIN_FILE=vcpkg/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static -DBUILD_SHARED=OFF -DSTATIC_BUILD=ON "-DCMAKE_INSTALL_PREFIX=%BASH_PREFIX%" .
if errorlevel 1 exit 1
cmake --build . --target install --config Release -j 5
if errorlevel 1 exit 1
