#!/bin/bash

set -ex

chmod +x $SRC_DIR/bazelisk-linux-amd64
$SRC_DIR/bazelisk-linux-amd64 build -c opt \
  --extra_toolchains=@llvm_toolchain//:cc-toolchain-x86_64-linux \
  //xls/dslx:interpreter_main \
  //xls/dslx:ir_converter_main \
  //xls/tools:opt_main \
  //xls/tools:codegen_main \
  //xls/tools:proto_to_dslx_main

mkdir -p $PREFIX/bin/
cp bazel-bin/xls/dslx/interpreter_main \
   bazel-bin/xls/dslx/ir_converter_main \
   bazel-bin/xls/tools/opt_main \
   bazel-bin/xls/tools/codegen_main \
   bazel-bin/xls/tools/proto_to_dslx_main $PREFIX/bin/
