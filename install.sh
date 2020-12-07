#!/bin/bash

source $TRAVIS_BUILD_DIR/.travis/common.sh
set -e

# Getting the conda environment
start_section "environment.conda" "Setting up basic ${YELLOW}conda environment${NC}"

branch=${TRAVIS_PULL_REQUEST_BRANCH:-$TRAVIS_BRANCH}
mkdir -p $BASE_PATH
./.travis/conda-get.sh $CONDA_PATH
hash -r

if [ x$PACKAGE = x"" ]; then
    echo '$PACKAGE not set, skipping the rest of install script'
    exit 0
fi

# Add '.travis' build variants to the recipe dir (appended keys win in case of any conflict)
cat "$TRAVIS_BUILD_DIR/.travis/conda_build_config.yaml" >> "$PACKAGE/conda_build_config.yaml"

# Install conda-build-prepare
python -m pip install git+https://github.com/antmicro/conda-build-prepare@v0.1#egg=conda-build-prepare

# The last channel will be on top of the environment's channel list
ADDITIONAL_CHANNELS="litex-hub $(echo $TRAVIS_REPO_SLUG | sed -e's@/.*$@@') litex-hub/label/travis-$branch-$TRAVIS_BUILD_ID $(echo $TRAVIS_REPO_SLUG | sed -e's@/.*$@@')/label/travis-$branch-$TRAVIS_BUILD_ID"

ADDITIONAL_PACKAGES="anaconda-client conda-build=3.20.3 conda-verify jinja2 pexpect python=3.7"
if [[ "$TRAVIS_OS_NAME" != 'windows' ]]; then
    ADDITIONAL_PACKAGES="$ADDITIONAL_PACKAGES ripgrep"
fi

# Prepare the recipe and create workdir/conda-env to be activated
python -m conda_build_prepare --channels $ADDITIONAL_CHANNELS --packages $ADDITIONAL_PACKAGES --dir workdir $PACKAGE

# Freshly created conda environment will be activated by the common.sh
source $TRAVIS_BUILD_DIR/.travis/common.sh

end_section "environment.conda"

$SPACER

# Output some useful info
start_section "info.conda.env" "Info on ${YELLOW}conda environment${NC}"
conda info
end_section "info.conda.env"

start_section "info.conda.config" "Info on ${YELLOW}conda config${NC}"
conda config --show
echo
conda config --show-sources
end_section "info.conda.config"

start_section "info.conda.package" "Info on ${YELLOW}conda package${NC}"
# This is the fully rendered metadata file
cat workdir/recipe/meta.yaml
end_section "info.conda.package"
