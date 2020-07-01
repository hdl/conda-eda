#!/bin/bash

source ./.travis/common.sh
set -e

# Close the after_success fold travis has created already.
travis_fold end after_success

if [[ $UPLOAD == "no-upload" ]]; then
    echo "Job without upload..."
else
    echo "Job with Conda upload..."

    if [ x$TRAVIS_BRANCH = x"master" -a x$TRAVIS_EVENT_TYPE != x"cron" -a x$TRAVIS_PULL_REQUEST == xfalse ]; then
    	$SPACER

    	start_section "package.upload" "${GREEN}Package uploading...${NC}"
    	anaconda -t $ANACONDA_TOKEN upload --user $ANACONDA_USER --label main $CONDA_OUT
    	end_section "package.upload"
    else
        echo "Conditions unmet, will not upload"
    fi

    $SPACER
fi

start_section "success.tail" "${GREEN}Success output...${NC}"
echo "Log is $(wc -l /tmp/output.log) lines long."
echo "Displaying last 1000 lines"
echo
tail -n 1000 /tmp/output.log
end_section "success.tail"
