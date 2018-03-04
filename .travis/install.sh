#!/bin/bash

source .travis/common.sh
set -e

# Git repo fixup
start_section "environment.git" "Setting up ${YELLOW}git checkout${NC}"
set -x
git fetch --tags
git submodule update --recursive --init
git submodule foreach git submodule update --recursive --init
set +x
end_section "environment.git"

$SPACER

# Getting the conda environment
start_section "environment.conda" "Setting up basic ${YELLOW}conda environment${NC}"

mkdir -p $BASE_PATH
./get-conda.sh $CONDA_PATH
hash -r
conda config --set always_yes yes --set changeps1 no
conda install pexpect
conda config --add channels timvideos
conda config --add channels $(echo $TRAVIS_REPO_SLUG | sed -e's@/.*$@@')
conda clean -s --dry-run
conda build purge
conda clean -s --dry-run

end_section "environment.conda"

$SPACER

# Output some useful info
start_section "info.conda.env" "Info on ${YELLOW}conda environment${NC}"
conda info
end_section "info.conda.env"

start_section "info.conda.package" "Info on ${YELLOW}conda package${NC}"
conda render $PACKAGE
end_section "info.conda.package"

start_section "info.autotools" "Info on ${YELLOW}autotools${NC}"
autoconf --version
automake --version
libtool --version
end_section "info.autotools"
