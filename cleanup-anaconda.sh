#!/bin/bash

#if the timestamp is older than one week, remove the whole label
ago="7 days ago"

#extract date in  milliseconds
limit_date=$(date $DATE_SWITCH "$ago" +'%s%N' | cut -b1-13)

echo "Will remove labels older than $limit_date timestamp"

for label in $(anaconda -t $ANACONDA_TOKEN label --list -o litex-hub 2>&1 | grep ' + ' | cut -f2 -d1+)
do
    if [[ $label != travis* ]]
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