#!/bin/bash

input=$VERSIONS
while IFS= read -r version
do
	export XILINX_VIVADO_VERSION=$version
	bash $TRAVIS_BUILD_DIR/.travis/script.sh
	bash $TRAVIS_BUILD_DIR/.travis/after_success.sh
done < "$input"
