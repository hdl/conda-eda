#!/bin/bash

source $TRAVIS_BUILD_DIR/.travis/common.sh

$SPACER

start_section "failure.tail" "${RED}Failure output...${NC}"
tail -n 1000 /tmp/output.log
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
