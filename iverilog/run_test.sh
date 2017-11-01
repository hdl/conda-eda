#!/bin/bash

set -x
set -e

cd test
iverilog -o test_fsm_tb fsm.v

echo "----------------------"
cat test_fsm_tb
echo "----------------------"

./test_fsm_tb
