#!/bin/bash

mkdir -p $PREFIX

curl -s https://storage.googleapis.com/symbiflow-arch-defs-gha/symbiflow-toolchain-latest | xargs wget -qO- | tar -xJC $PREFIX
