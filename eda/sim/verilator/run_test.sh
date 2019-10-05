#!/bin/bash

set -e
set +x

$PREFIX/bin/verilator -V
#$PREFIX/bin/verilator --help || true

function run {
	FILENAME=$1
	rm -rf sim_main.cpp
	rm -rf obj_dir

	cat <<EOF >sim_main.cpp
#include "V$FILENAME.h"
#include "verilated.h"
int main(int argc, char **argv, char **env) {
    Verilated::commandArgs(argc, argv);
    V$FILENAME* top = new V$FILENAME;
    while (!Verilated::gotFinish()) { top->eval(); }
    exit(0);
}
EOF
	$PREFIX/bin/verilator --cc $FILENAME.v $2 $3 --exe sim_main.cpp
	cd obj_dir
	cat V$FILENAME.mk
	make -j -f V$FILENAME.mk V$FILENAME
	cd ..
	obj_dir/V$FILENAME

	rm -rf sim_main.cpp
	rm -rf obj_dir
}

cd test

# Hello world test
echo
echo
echo "Hello World Test ====="
run hello_world
echo "----------------------"

# Counter
echo
echo
echo "Counter Test ========="
# FIXME
# %Error: counter_tb.v:21: Unsupported or unknown PLI call: $monitor
# %Error: counter.v:18: Unsupported: Verilog 1995 deassign
#run counter_tb counter.v
echo "----------------------"
