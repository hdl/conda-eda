#!/bin/bash

# `for ... in $(anaconda ...` fails silently if there's any problem with anaconda
source $TRAVIS_BUILD_DIR/.travis/test_anaconda.sh

branch=${TRAVIS_PULL_REQUEST_BRANCH:-$TRAVIS_BRANCH}
# Move all packages from the current label to the main label
for package in $(anaconda -t $ANACONDA_TOKEN label --show travis-$branch-$TRAVIS_BUILD_ID 2>&1 | grep + | cut -f2 -d+)
do
    anaconda -t $ANACONDA_TOKEN move --from-label travis-$branch-$TRAVIS_BUILD_ID --to-label main $package
done
