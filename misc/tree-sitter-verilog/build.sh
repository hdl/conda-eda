#! /bin/bash

set -e
set -x

npm install tree-sitter-cli

./node_modules/tree-sitter-cli/tree-sitter generate

$PYTHON -m pip install --isolated tree_sitter
$PYTHON -c "from tree_sitter import Language; Language.build_library(\"$PREFIX/lib/tree-sitter-verilog.so\", [\".\"])"
$PYTHON -m pip uninstall -y tree_sitter
