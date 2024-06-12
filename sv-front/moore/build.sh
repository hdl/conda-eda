#!/bin/bash

set -e
set -x

git submodule update --depth=1 --init --recursive

# Build LLVM and MLIR

mkdir -p circt/llvm/build
pushd circt/llvm/build
cmake ../llvm \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=../install \
    -DLLVM_BUILD_EXAMPLES=OFF \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_BINDINGS=OFF \
    -DLLVM_ENABLE_OCAMLDOC=OFF \
    -DLLVM_ENABLE_PROJECTS=mlir \
    -DLLVM_INSTALL_UTILS=ON \
    -DLLVM_OPTIMIZED_TABLEGEN=ON \
    -DLLVM_TARGETS_TO_BUILD=""
cmake --build . --target install
popd

# Build CIRCT

mkdir -p circt/build
pushd circt/build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=../install \
    -DMLIR_DIR=$PWD/../llvm/install/lib/cmake/mlir \
    -DLLVM_DIR=$PWD/../llvm/install/lib/cmake/llvm \
    -DLLVM_ENABLE_ASSERTIONS=ON
cmake --build . --target install
popd

# Build Moore

export CIRCT_SYS_CIRCT_DIR=$PWD/circt
export CIRCT_SYS_CIRCT_BUILD_DIR=$PWD/circt/install
export CIRCT_SYS_LLVM_DIR=$PWD/circt/llvm
export CIRCT_SYS_LLVM_BUILD_DIR=$PWD/circt/llvm/install

curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

cargo build --release
install -D target/release/moore $PREFIX/bin/moore

$PREFIX/bin/moore --version
