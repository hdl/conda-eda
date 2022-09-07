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

# sanity check
test -d $SRC_DIR/gf180mcu-pdk/gf180mcu_fd_pr
test -d $SRC_DIR/gf180mcu-pdk/gf180mcu_fd_io
test -d $SRC_DIR/gf180mcu-pdk/gf180mcu_fd_sc_mcu7t5v0
test -d $SRC_DIR/gf180mcu-pdk/gf180mcu_fd_sc_mcu9t5v0    
test -d $SRC_DIR/gf180mcu-pdk/gf180mcu_fd_ip_sram
test -d $SRC_DIR/gf180mcu-pdk/gf180mcu_osu_sc

# extract variant name from package name
VARIANT=${PKG_NAME#open_pdks.gf180mcu}
VARIANT=${VARIANT^^}

# --enable-gf180-pdk: point to current checkout
# --with-gf180-variants: use specified variant 
./configure --prefix=$PREFIX \
  --enable-gf180mcu-pdk=$SRC_DIR/gf180mcu-pdk \
  --with-gf180mcu-variants=$VARIANT
make V=1
make V=1 install
