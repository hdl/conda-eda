#!/bin/bash

source $TRAVIS_BUILD_DIR/.travis/common.sh

# Close the after_failure fold travis has created already.
travis_fold end after_failure

$SPACER

start_section "failure.tail" "${RED}Failure output...${NC}"
echo "Log is $(wc -l /tmp/output.log) lines long."
echo "Displaying last 1000 lines"
echo
tail -n 1000 /tmp/output.log
end_section "failure.tail"

$SPACER

#COUNT=0
#for i in $(find $BASE_PATH -name config.log); do
#	start_section "failure.log.$COUNT" "${RED}Failure output $i...${NC}"
#	cat $i
#	end_section "failure.log.$COUNT"
#	COUNT=$((COUNT+1))
#done
#
#$SPACER

start_section "failure.log.full" "${RED}Failure output.log...${NC}"
cat /tmp/output.log
end_section "failure.log.full"
