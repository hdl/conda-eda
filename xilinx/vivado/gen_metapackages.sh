#!/bin/bash

echo "Versions file: $VERSIONS"
cat "$VERSIONS"
input=$VERSIONS
while IFS= read -r version
do
	export XILINX_VIVADO_VERSION=$version

	# Initialize Conda
	. $GITHUB_WORKSPACE/.github/scripts/common.sh
	eval "$('conda' 'shell.bash' 'hook' 2> /dev/null)"

	# Remove previously prepared recipe directory
	rm -rf workdir

	# Prepare recipe with currently set version (cbp is installed in `base` environment)
	conda activate base
	ADDITIONAL_PACKAGES="anaconda-client conda-build=3.20.3 conda-verify jinja2 pexpect python=3.7 ripgrep"
	python -m conda_build_prepare --dir workdir --packages $ADDITIONAL_PACKAGES -- $PACKAGE

	# Build metapackage
	bash $GITHUB_WORKSPACE/.github/scripts/script.sh
	bash $GITHUB_WORKSPACE/.github/scripts/after_success.sh
done < "$input"
