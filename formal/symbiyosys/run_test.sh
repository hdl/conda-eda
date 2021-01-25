#!/bin/bash

set -e
set +x

echo "TEST: pwd=`pwd`"
echo "TEST: dir: `ls`"

# `|| true` is needed because of the `set -e` option.
$PREFIX/bin/sby test/demo3.sby > output 2>&1 || true

passed=`grep 'Status: passed' output | wc -l`

if test $passed -ne 1; then
  echo "Error: test failed"
  cat output
  exit 1
fi

