#!/bin/bash

set -e
set -x

which pkg-config

echo "PREFIX := $PREFIX" >> Makefile.conf

# create local symlinks not to polute the package contents
mkdir -p "$PWD/.local/bin"
export PATH="$PWD/.local/bin:$PATH"
ln -s $(which antmicro-yosys) $PWD/.local/bin/yosys
ln -s $(which antmicro-yosys-config) $PWD/.local/bin/yosys-config

cd yosys-symbiflow-plugins
make install -j$CPU_COUNT
