#!/bin/bash

set -ex

bazel build -c opt \
  --extra_toolchains=@llvm_toolchain//:cc-toolchain-x86_64-linux \
  //xls/dslx:interpreter_main \
  //xls/dslx:ir_converter_main \
  //xls/tools:opt_main \
  //xls/tools:codegen_main

cp bazel-bin/xls/dslx/interpreter_main \
   bazel-bin/xls/dslx/ir_converter_main \
   bazel-bin/xls/tools/opt_main \
   bazel-bin/xls/tools/codegen_main $PREFIX/bin/
