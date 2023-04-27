#!/bin/bash

set -ex

# build targets
chmod +x $SRC_DIR/bazelisk-linux-amd64
$SRC_DIR/bazelisk-linux-amd64 build -c opt \
			      --extra_toolchains=@llvm_toolchain//:cc-toolchain-x86_64-linux \
			      //xls/dslx:interpreter_main \
			      //xls/dslx/ir_convert:ir_converter_main \
			      //xls/tools:opt_main \
			      //xls/tools:codegen_main \
			      //xls/tools:proto_to_dslx_main \
			      //xls/contrib/xlscc:xlscc \
			      //xls/tools:package_bazel_build

# install targets
mkdir -p $PREFIX/share/xls
bazel-bin/xls/tools/package_bazel_build --output_dir $PREFIX/share/xls \
					--inc_target xls/dslx/interpreter_main \
					--inc_target xls/dslx/ir_convert/ir_converter_main \
					--inc_target xls/tools/opt_main \
					--inc_target xls/tools/codegen_main \
					--inc_target xls/tools/proto_to_dslx_main \
                                        --inc_target xls/contrib/xlscc/xlscc

# create tools symlinks
mkdir -p $PREFIX/bin
for f in xls/dslx/interpreter_main \
	 xls/dslx/ir_convert/ir_converter_main \
	 xls/tools/opt_main \
	 xls/tools/codegen_main \
	 xls/tools/proto_to_dslx_main \
         xls/contrib/xlscc/xlscc
do
    ln -sr $PREFIX/share/xls/$f $PREFIX/bin/$(basename $f)
done
