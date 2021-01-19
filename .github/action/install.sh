#!/bin/bash

source $GITHUB_WORKSPACE/.github/scripts/common.sh
set -e

# Getting the conda environment
start_section "environment.conda" "Setting up basic ${YELLOW}conda environment${NC}"

branch="$(git rev-parse --abbrev-ref HEAD)"
mkdir -p $BASE_PATH
$GITHUB_WORKSPACE/.github/scripts/conda-get.sh $CONDA_PATH
hash -r

if [ x$PACKAGE = x"" ]; then
    echo '$PACKAGE not set, skipping the rest of install script'
    exit 0
fi

# Add build variants to the recipe dir (appended keys win in case of any conflict)
cat "$GITHUB_WORKSPACE/.github/scripts/conda_build_config.yaml" >> "$PACKAGE/conda_build_config.yaml"

# Install conda-build-prepare
python -m pip install git+https://github.com/litex-hub/conda-build-prepare@solve-ci-label-issue#egg=conda-build-prepare

# The last channel will be on top of the environment's channel list
ADDITIONAL_CHANNELS="litex-hub $(echo $GITHUB_REPOSITORY | sed -e's@/.*$@@') litex-hub/label/ci-$branch-$GITHUB_RUN_ID $(echo $GITHUB_REPOSITORY | sed -e's@/.*$@@')/label/ci-$branch-$GITHUB_RUN_ID"

ADDITIONAL_PACKAGES="conda-build=3.20.3 conda-verify jinja2 pexpect python=3.7"
if [[ "$OS_NAME" != 'windows' ]]; then
    ADDITIONAL_PACKAGES="$ADDITIONAL_PACKAGES ripgrep"
fi

# Prepare the recipe and create workdir/conda-env to be activated
python -m conda_build_prepare --channels $ADDITIONAL_CHANNELS --packages $ADDITIONAL_PACKAGES --dir workdir $PACKAGE

# Freshly created conda environment will be activated by the common.sh
source $GITHUB_WORKSPACE/.github/scripts/common.sh

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
