#!/bin/bash

source ./.travis/common.sh
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
if [[ $TRAVIS_OS_NAME != 'windows' ]]; then
    if [[ $KEEP_ALIVE = 'true' ]]; then
        travis_wait $TRAVIS_MAX_TIME $CONDA_PATH/bin/python $TRAVIS_BUILD_DIR/.travis/.travis-output.py /tmp/output.log conda build $CONDA_BUILD_ARGS
    else
        $CONDA_PATH/bin/python $TRAVIS_BUILD_DIR/.travis/.travis-output.py /tmp/output.log conda build $CONDA_BUILD_ARGS
    fi
else
    # Work-around: prevent console output being mangled
    winpty.exe -Xallow-non-tty -Xplain conda build $CONDA_BUILD_ARGS 2>&1 | tee /tmp/output.log
fi
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
