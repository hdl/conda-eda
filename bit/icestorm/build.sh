#!/bin/bash

set -e
set -x

make -j$CPU_COUNT

make install

icetime -h || true
