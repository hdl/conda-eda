#!/bin/bash

./configure --prefix="$PREFIX" \
    --disable-udev
make
make install

