#!/bin/bash

source $CI_SCRIPTS_PATH/common.sh

# Close the after_failure fold
echo ::endgroup::

$SPACER

start_section "failure.tail" "${RED}Failure output...${NC}"
echo "Log is $(wc -l /tmp/output.log) lines long."
echo "Displaying last 1000 lines"
echo
tail -n 1000 /tmp/output.log
end_section "failure.tail"

$SPACER

start_section "failure.log.full" "${RED}Failure output.log...${NC}"
cat /tmp/output.log
end_section "failure.log.full"
