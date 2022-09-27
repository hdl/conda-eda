#!/bin/bash

set -ex

cat >> $PREFIX/share/openlane/install/env.tcl <<EOF
set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"
set ::env(STD_CELL_LIBRARY_OPT) "sky130_fd_sc_hd"
EOF
