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

cd $SRC_DIR/blas
cmake -B build -DCMAKE_INSTALL_PREFIX=$PREFIX .
cmake --build build -j $CPU_COUNT --target install

cd $SRC_DIR/lapack
cmake -B build -DCMAKE_INSTALL_PREFIX=$PREFIX .
cmake --build build -j $CPU_COUNT --target install

cd $SRC_DIR/amd
cmake -B build -DSuiteSparsePath=. -DCMAKE_INSTALL_PREFIX=$PREFIX $SRC_DIR/cmake/trilinos/AMD
cmake --build build -j $CPU_COUNT --target install

cd $SRC_DIR/Trilinos
cmake -B build -DCMAKE_INSTALL_PREFIX=$PREFIX -C $SRC_DIR/cmake/trilinos/trilinos-config.cmake . 
cmake --build build -j $CPU_COUNT --target install

cd $SRC_DIR
cmake -B build -DCMAKE_INSTALL_PREFIX=$PREFIX .
cmake --build build -j $CPU_COUNT --target install
