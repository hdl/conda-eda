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
    *)          OS="${UNAME_OUT}"
                echo "Unknown OS: ${OS}"
                exit;;
esac

mkdir -p $PREFIX/share/openlane
git archive HEAD | tar -xv -C $PREFIX/share/openlane
# define system and pdk variables
mkdir -p $PREFIX/share/openlane/install
echo $PKG_VERSION-conda > $PREFIX/share/openlane/install/installed_version
cp -a $RECIPE_DIR/env.tcl $PREFIX/share/openlane/install/
mkdir -p $PREFIX/share/openlane/install/build/versions
touch $PREFIX/share/openlane/install/build/versions/keep-directory
# override default configuration to disable missing tools
cp -a $RECIPE_DIR/disable-missing-tools.tcl $PREFIX/share/openlane/configuration/disable-missing-tools.tcl
echo -n ' disable-missing-tools.tcl' >> $PREFIX/share/openlane/configuration/load_order.txt
# add flow.tcl shortcut
mkdir -p $PREFIX/bin
cat > $PREFIX/bin/flow.tcl <<EOF
#!/usr/bin/env tclsh
lappend argv "-ignore_mismatches"
source "$::env(CONDA_PREFIX)/share/openlane/flow.tcl"
EOF
chmod +x $PREFIX/bin/flow.tcl
