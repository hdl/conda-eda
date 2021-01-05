#!/bin/bash

echo
if [ x$ANACONDA_TOKEN != x ]; then
    if ! anaconda -h &>/dev/null; then
        echo 'ERROR: Missing `anaconda-client` package!'
        echo 'This Conda environment contains the following packages:'
        conda list
    else
        echo 'Testing ANACONDA_TOKEN with a simple `anaconda` call...'
        if anaconda -t $ANACONDA_TOKEN label --show main &>/dev/null; then
            echo 'ANACONDA_TOKEN works!'
            exit 0
        else
            echo 'ERROR: Invalid ANACONDA_TOKEN!'
        fi
    fi
else
    echo 'ERROR: ANACONDA_TOKEN not set!'
fi
echo

# We only get here when anaconda/token doesn't work
exit 1
