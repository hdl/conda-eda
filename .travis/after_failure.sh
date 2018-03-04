#!/bin/bash

source .travis/common.sh
set -e

# Close the after_success.1 fold travis has created already.
travis_time_finish
travis_fold end after_failure.1

start_section "failure.tail" "${RED}Failure output...${NC}"
tail -n 1000 output.log
end_section "failure.tail"

$SPACER

COUNT=0
for i in $(find $BASE_PATH -name config.log); do
	start_section "failure.log.$COUNT" "${RED}Failure output $i...${NC}"
	cat $i
	end_section "failure.log.$COUNT"
	COUNT=$((COUNT+1))
done

$SPACER

start_section "failure.log.full" "${RED}Failure output.log...${NC}"
cat output.log
end_section "failure.log.full"
