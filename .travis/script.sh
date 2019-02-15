#!/bin/bash

source .travis/common.sh
set -e

$SPACER

start_section "info.conda.package" "Info on ${YELLOW}conda package${NC}"
conda render $CONDA_BUILD_ARGS
end_section "info.conda.package"

$SPACER

start_section "conda.check" "${GREEN}Checking...${NC}"
conda build --check $CONDA_BUILD_ARGS || true
end_section "conda.check"

$SPACER

start_section "conda.build" "${GREEN}Building..${NC}"
$CONDA_PATH/bin/python $TRAVIS_BUILD_DIR/.travis-output.py /tmp/output.log conda build $CONDA_BUILD_ARGS
end_section "conda.build"

$SPACER

start_section "conda.build" "${GREEN}Installing..${NC}"
conda install $CONDA_OUT
end_section "conda.build"

$SPACER

start_section "conda.du" "${GREEN}Disk usage..${NC}"
du -h $CONDA_OUT
end_section "conda.du"

$SPACER

start_section "conda.clean" "${GREEN}Cleaning up..${NC}"
#conda clean -s --dry-run
end_section "conda.clean"

$SPACER
