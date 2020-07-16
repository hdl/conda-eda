#!/bin/bash

source ./.travis/common.sh
set -e

# Close the after_success fold travis has created already.
travis_fold end after_success

if [[ $UPLOAD == "no-upload" ]]; then
    echo "Job without upload..."
else
    echo "Job with Conda upload..."

    $SPACER
    # Travis will not expose the ANACONDA_TOKEN var for pull requests coming from other forks than the original one
    if [ x$ANACONDA_TOKEN != x ]; then
        start_section "package.upload" "${GREEN}Package uploading...${NC}"
        anaconda -t $ANACONDA_TOKEN upload --no-progress --user $ANACONDA_USER --label travis-${TRAVIS_PULL_REQUEST_BRANCH:-$TRAVIS_BRANCH}-$TRAVIS_BUILD_ID $CONDA_OUT
        end_section "package.upload"
    else
        echo "ANACONDA_TOKEN not found. Please consult README of litex-conda-ci for details on setting up Travis tests properly."
        echo "Packages cannot be uploaded when tests are running for cross-repository Pull Requests."
    fi

    $SPACER
fi

start_section "success.tail" "${GREEN}Success output...${NC}"
echo "Log is $(wc -l /tmp/output.log) lines long."
echo "Displaying last 1000 lines"
echo
tail -n 1000 /tmp/output.log
end_section "success.tail"
