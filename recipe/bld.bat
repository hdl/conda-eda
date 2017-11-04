copy %RECIPE_DIR%\CMakeLists.txt .
copy %RECIPE_DIR%\isl_config.h.cmake .
copy %RECIPE_DIR%\isl_srcdir.c.cmake .
mkdir build
cd build
cmake -G"NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ..
cmake --build .
cmake --build . --target install
ctest -V
