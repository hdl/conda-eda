#!/bin/bash

input=$VERSIONS
while IFS= read -r version
do
	export XILINX_VIVADO_VERSION=$version

	# Initialize Conda
	. $TRAVIS_BUILD_DIR/.travis/common.sh
	eval "$('conda' 'shell.bash' 'hook' 2> /dev/null)"

	# Remove previously prepared recipe directory
	rm -rf workdir

	# Prepare recipe with currently set version (cbp is installed in `base` environment)
	conda activate base
	ADDITIONAL_PACKAGES="anaconda-client conda-build=3.20.3 conda-verify jinja2 pexpect python=3.7 ripgrep"
	python -m conda_build_prepare --dir workdir --packages $ADDITIONAL_PACKAGES -- $PACKAGE

	# Build metapackage
	bash $TRAVIS_BUILD_DIR/.travis/script.sh
	bash $TRAVIS_BUILD_DIR/.travis/after_success.sh
done < "$input"
