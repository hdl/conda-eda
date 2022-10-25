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

# https://github.com/hdl/conda-eda/issues/174
set ::env(RUN_CVC) 0
# https://github.com/The-OpenROAD-Project/OpenLane/issues/1380
set ::env(RUN_LVS) 0
# https://github.com/hdl/conda-eda/issues/175
set ::env(RUN_KLAYOUT) 0
set ::env(RUN_KLAYOUT_XOR) 0