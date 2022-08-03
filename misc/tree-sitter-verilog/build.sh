#! /bin/bash

set -e
set -x

npm install tree-sitter-cli

./node_modules/tree-sitter-cli/tree-sitter generate

# Build the 'tree_sitter/binding' extension.
cd py-tree-sitter
python3 setup.py build --build-lib .

python3 -c 'from tree_sitter import Language; Language.build_library("tree-sitter-verilog.so", [".."])'
mv tree-sitter-verilog.so $PREFIX/lib/
