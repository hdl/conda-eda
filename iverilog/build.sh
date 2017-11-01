#!/bin/bash

set -e
set -x

export CXXFLAGS=-Wno-deprecated-declarations

sh ./autoconf.sh
./configure --prefix=$PREFIX

make -j$CPU_COUNT
make install

$PREFIX/bin/iverilog -V
$PREFIX/bin/iverilog -h || true

cat > hello_world.v <<'EOF'
module hello_world;
initial begin
	$display("Hello World!");
	#10 $finish;
end
endmodule
EOF
$PREFIX/bin/iverilog -v hello_world.v
