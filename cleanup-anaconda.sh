#!/bin/bash

source $GITHUB_WORKSPACE/.github/scripts/common.sh
# `for ... in $(anaconda ...` fails silently if there's any problem with anaconda
source $GITHUB_WORKSPACE/.github/scripts/test_anaconda.sh
set -x

#if the timestamp is older than one week, remove the whole label
ago="7 days ago"

if [ $OS_NAME = 'osx' ]; then
    DATE_SWITCH="-r "
else
    DATE_SWITCH="--date "
fi

#extract date in  milliseconds
limit_date=$(date $DATE_SWITCH "$ago" +'%s%N' | cut -b1-13)

echo "Will remove labels older than $limit_date timestamp"

for label in $(anaconda -t $ANACONDA_TOKEN label --list -o litex-hub 2>&1 | grep ' + ' | cut -f2 -d+)
do
    if [[ $label != ci* ]]
    then
        continue
    fi

    label_info=$(anaconda -t $ANACONDA_TOKEN label -o litex-hub --show label-name 2>&1)
    #filter first package from the label. Packages start with '+' and have too many whitespace chars (thus xargs)
    package=$(anaconda -t $ANACONDA_TOKEN label -o litex-hub --show $label 2>&1 | grep ' + ' | cut -f2 -d+ | head -n1 | xargs)
    #extract build timestamp
    timestamp=$(anaconda -t $ANACONDA_TOKEN show $package 2>&1 | grep timestamp | cut -f2 -d: | xargs)

    if [[ $timestamp -lt $limit_date ]]
    then
        echo "Removing old label $label with timestamp $timestamp"
        anaconda -t $ANACONDA_TOKEN label -o litex-hub --remove $label
    else
        echo "Not removing label $label with timestamp $timestamp"
    fi

done