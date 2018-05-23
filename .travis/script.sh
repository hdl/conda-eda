#!/bin/bash

source .travis/common.sh
set -e

$SPACER

start_section "conda.copy" "${GREEN}Copying package...${NC}"
mkdir -p /tmp/conda
cp -avR $PACKAGE /tmp/conda/
cd /tmp/conda/
end_section "conda.copy"

$SPACER

start_section "conda.check" "${GREEN}Checking...${NC}"
conda build --check $PACKAGE
end_section "conda.check"

$SPACER

start_section "conda.build" "${GREEN}Building..${NC}"
$CONDA_PATH/bin/python ./.travis-output.py output.log conda build $PACKAGE
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
conda clean -s --dry-run
end_section "conda.clean"

$SPACER
