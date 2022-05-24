#!/bin/bash

source $CI_SCRIPTS_PATH/common.sh
set -e

# Getting the conda environment
start_section "environment.conda" "Setting up basic ${YELLOW}conda environment${NC}"

mkdir -p $BASE_PATH
$CI_SCRIPTS_PATH/conda-get.sh $CONDA_PATH
hash -r

if [ x$PACKAGE = x"" ]; then
    echo '$PACKAGE not set, skipping the rest of install script'
    exit 0
fi

# Add build variants to the recipe dir (appended keys win in case of any conflict)
cat "$CI_SCRIPTS_PATH/conda_build_config.yaml" >> "$PACKAGE/conda_build_config.yaml"

# Install conda-build-prepare
python -m pip install git+https://github.com/hdl/conda-build-prepare@v0.1.2#egg=conda-build-prepare

# ANACONDA_USER isn't available in cross-repository PRs
if [ "$ANACONDA_USER" != "" ]; then
    branch="$(git rev-parse --abbrev-ref HEAD)"
    # The last channel will be on top of the environment's channel list
    ADDITIONAL_CHANNELS="litex-hub $ANACONDA_USER $ANACONDA_USER/label/ci-$branch-$GITHUB_RUN_ID"
else
    ADDITIONAL_CHANNELS="litex-hub"
fi

ADDITIONAL_PACKAGES="conda-build conda-verify jinja2 pexpect python=3.7"
if [[ "$OS_NAME" != 'windows' ]]; then
    ADDITIONAL_PACKAGES="$ADDITIONAL_PACKAGES ripgrep"
fi

# Prepare the recipe and create workdir/conda-env to be activated
python -m conda_build_prepare --channels $ADDITIONAL_CHANNELS --packages $ADDITIONAL_PACKAGES --dir workdir $PACKAGE

# Freshly created conda environment will be activated by the common.sh
source $CI_SCRIPTS_PATH/common.sh

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
