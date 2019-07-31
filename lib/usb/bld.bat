cd "%SRC_DIR%"
7z x libusb.7z

if "%ARCH%"=="32" (
copy "MinGW32\dll\libusb-1.0.dll" "%PREFIX%\Library\bin\"
copy "MinGW32\dll\libusb-1.0.dll.a" "%PREFIX%\Library\lib\"
) else (
copy "MinGW64\dll\libusb-1.0.dll" "%PREFIX%\Library\bin\"
copy "MinGW64\dll\libusb-1.0.dll.a" "%PREFIX%\Library\lib\"
)
xcopy /e "include" "%PREFIX%\Library\include"
