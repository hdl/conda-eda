#!/bin/bash

set -ex

bazel build -c opt //xls:dist

tar -xvzf bazel-bin/xls/dist.tar.gz -C $PREFIX
