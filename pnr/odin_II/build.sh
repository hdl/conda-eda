#!/bin/bash

set -e
set -x

CPU_COUNT=$(nproc)

cd ODIN_II
make build -j$CPU_COUNT
install -D odin_II $PREFIX/bin/odin_II
