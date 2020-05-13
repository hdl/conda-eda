#!/bin/bash

source $TRAVIS_BUILD_DIR/.travis/common.sh
set -e

# Getting the conda environment
start_section "environment.conda" "Setting up basic ${YELLOW}conda environment${NC}"

mkdir -p $BASE_PATH
./conda-get.sh $CONDA_PATH
hash -r
conda config --set always_yes yes --set changeps1 no
conda install pexpect
conda config --add channels litex-hub
conda config --add channels antmicro
conda config --add channels $(echo $TRAVIS_REPO_SLUG | sed -e's@/.*$@@')

if [ -e $PACKAGE/condarc_$TRAVIS_OS_NAME ]; then
	export PACKAGE_CONDARC=$PACKAGE/condarc_$TRAVIS_OS_NAME
elif [ -e $PACKAGE/condarc ]; then
	export PACKAGE_CONDARC=$PACKAGE/condarc
fi

if [ -e "$PACKAGE_CONDARC" ]; then
	# Slightly decrease priority of the settings made with 'conda config'
	if [ ! -d ~/.conda ]; then
		mkdir ~/.conda
	fi
	mv ~/.condarc ~/.conda/.condarc

	# Use package's condarc as the most important one for 'conda build'
	# (only environment's condarc could be more important)
	cp $PACKAGE_CONDARC ~/.condarc
fi

#conda clean -s --dry-run
conda build purge
#conda clean -s --dry-run

./conda-meta-extra.sh $PACKAGE

end_section "environment.conda"

$SPACER

# Output some useful info
start_section "info.conda.env" "Info on ${YELLOW}conda environment${NC}"
conda info
end_section "info.conda.env"

start_section "info.conda.config" "Info on ${YELLOW}conda config${NC}"
conda config --show
end_section "info.conda.config"

start_section "info.conda.package" "Info on ${YELLOW}conda package${NC}"
conda render --no-source $CONDA_BUILD_ARGS || true
end_section "info.conda.package"

$SPACER

start_section "conda.copy" "${GREEN}Copying package...${NC}"
mkdir -p /tmp/conda/$PACKAGE
cp -vRL $PACKAGE/* /tmp/conda/$PACKAGE/
cd /tmp/conda/
end_section "conda.copy"

$SPACER

start_section "conda.download" "${GREEN}Downloading..${NC}"
travis_wait conda build --source $CONDA_BUILD_ARGS || true
end_section "conda.download"

if [ -e $PACKAGE/prescript.$TOOLCHAIN_ARCH.sh ]; then
	start_section "conda.prescript" "${GREEN}Prescript..${NC}"
	(
		cd $TRAVIS_BUILD_DIR
		$PACKAGE/prescript.$TOOLCHAIN_ARCH.sh
	)
	end_section "conda.prescript"
fi
