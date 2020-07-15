#!/bin/bash

# Move all packages from the current label to the main label
for package in $(anaconda -t $ANACONDA_TOKEN label --show travis-$TRAVIS_BUILD_ID 2>&1 | grep + | cut -f2 -d+)
do
    anaconda -t $ANACONDA_TOKEN move --from-label travis-$TRAVIS_BUILD_ID --to-label main $package
done
