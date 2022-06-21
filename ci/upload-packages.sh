#!/bin/bash

set -x

source $CI_SCRIPTS_PATH/common.sh
# `for ... in $(anaconda ...` fails silently if there's any problem with anaconda
source $CI_SCRIPTS_PATH/test_anaconda.sh

branch="$(git rev-parse --abbrev-ref HEAD)"
# Move all packages from the current label to the main label
for package in $(anaconda -t $ANACONDA_TOKEN label --show ci-$branch-$GITHUB_RUN_ID 2>&1 | grep + | cut -f2 -d+)
do
    anaconda -t $ANACONDA_TOKEN move --from-label ci-$branch-$GITHUB_RUN_ID --to-label main $package
done
