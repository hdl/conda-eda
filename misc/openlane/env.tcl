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

# define system variables
set ::env(OPENLANE_ROOT) "$::env(CONDA_PREFIX)/share/openlane"
set ::env(OL_INSTALL_DIR) "$::env(CONDA_PREFIX)/share/openlane/install"
set ::env(OPENLANE_LOCAL_INSTALL) 1
set ::env(TCLLIBPATH) [glob -type d "$::env(CONDA_PREFIX)/lib/tcllib*"]
lappend ::auto_path $::env(TCLLIBPATH)
# default to conda-install PDKs
if { ! [info exists ::env(PDK_ROOT)] } {
    set ::env(PDK_ROOT) "$::env(CONDA_PREFIX)/share/pdk"
}
