#!/bin/bash

source $GITHUB_WORKSPACE/.github/scripts/common.sh
set -e

start_section "conda.clean.1" "${GREEN}Clean status...${NC}"
#conda clean -s --dry-run
end_section "conda.clean.1"

start_section "conda.clean.2" "${GREEN}Cleaning...${NC}"
conda build purge
end_section "conda.clean.2"

start_section "conda.clean.3" "${GREEN}Clean status...${NC}"
#conda clean -s --dry-run
end_section "conda.clean.3"
