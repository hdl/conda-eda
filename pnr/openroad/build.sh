#!/bin/bash


# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

# Identify OS
UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     OS=Linux;;
    Darwin*)    OS=Mac;;
    *)          OS="${UNAME_OUT}"
                echo "Unknown OS: ${OS}"
                exit;;
esac

if [[ $OS == "Mac" ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
    cd $PREFIX
    # This is required because we have an external SDK file. The default
    # Qt build explicitly looks for the SDK in /System/Library/Frameworks/
    # and ignores any attempt to set the SDK root any other way.
    if grep -q _GL_INCDIRS "$PREFIX/lib/cmake/Qt5Gui/Qt5GuiConfigExtras.cmake"; then
        sed '1,11d' < "$PREFIX/lib/cmake/Qt5Gui/Qt5GuiConfigExtras.cmake" | sed '1 s|.*|set(_qt5gui_OPENGL_INCLUDE_DIR "'$CONDA_BUILD_SYSROOT'/System/Library/Frameworks/OpenGL.framework/Headers")|' > "$PREFIX/lib/cmake/Qt5Gui/Qt5GuiConfigExtras.cmake.bak"
        mv "$PREFIX/lib/cmake/Qt5Gui/Qt5GuiConfigExtras.cmake.bak" "$PREFIX/lib/cmake/Qt5Gui/Qt5GuiConfigExtras.cmake"
    fi
fi

cd $SRC_DIR/third_party/lemon
cmake -B build  -DCMAKE_INSTALL_PREFIX=$PREFIX .
cmake --build build -j $CPU_COUNT --target install

cd $SRC_DIR
cmake -B build -DTCL_LIB_PATHS="$BUILD_PREFIX;$PREFIX" -DCMAKE_FIND_ROOT_PATH="$BUILD_PREFIX;$PREFIX" -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=ONLY -DUSE_SYSTEM_BOOST=ON -DINSTALL_LIBOPENSTA=OFF -DBUILD_MPL2=OFF -DBUILD_PAR=OFF -DENABLE_TESTS=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX .
cmake --build build -j $CPU_COUNT --target install
