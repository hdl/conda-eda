#!/bin/bash

source $CI_SCRIPTS_PATH/common.sh
# `for ... in $(anaconda ...` fails silently if there's any problem with anaconda
source $CI_SCRIPTS_PATH/test_anaconda.sh

set -e
set -x

#print cleanup summary before exiting
log_file=$GITHUB_WORKSPACE/cleanup.log
echo "RESULT;LABELS;NDOWNLOADS;PACKAGE" >$log_file
function print_log {
    end_section  # in case exiting inside a section
    start_section "Cleanup summary"
    column -t -s ';' <$log_file
    end_section
}
trap print_log EXIT

#packages will be removed if their label is older than 'ago'
ago="30 days ago"
#packages won't be removed if they were downloaded more than 'download_threshold' times
download_threshold=30

#extract Conda-styled timestamp, i.e., MILLIseconds since the epoch (hence the `%3N`)
limit_date=$(date --date="$ago" +'%s%3N')

echo "[CLEANUP] Will remove packages older than $ago with no more than $download_threshold downloads\n"

#anaconda prints requested data to stderr
function anaconda_stdout {
    anaconda -t $ANACONDA_TOKEN $@ 2>&1 | tr -s ' '
}

for label in $(anaconda_stdout label -o $ANACONDA_USER --list | grep -oP '(?<= \+ )ci-[^ ]+')
do
    start_section "Label $label"

    #extra label check
    if [[ "${label:0:3}" != "ci-" ]]
    then
        echo "[CLEANUP] Omitting non-ci label $label."
        end_section
        continue
    fi

    #get label packages
    packages=$(anaconda_stdout label -o $ANACONDA_USER --show $label | grep -oP '(?<= \+ )[^ ]+')

    #check build timestamp of the first package
    package=$(echo "$packages" | head -n1)
    timestamp=$(anaconda_stdout show $package | grep -oP '(?<=timestamp : )[0-9]+')
    label_date=$(date --date=@${timestamp:0:-3})

    if [[ $timestamp -gt $limit_date ]]
    then
        echo "[CLEANUP] Not removing label $label with timestamp $timestamp ($label_date)"
        end_section
        continue
    fi

    echo "[CLEANUP] Removing packages from the old label $label with timestamp $timestamp ($label_date)"
    for package in $packages
    do
        metadata=$(anaconda_stdout show $package)

        labels=$(echo "$metadata" | grep -oP '(?<=labels : ).+')
        ndownloads=$(echo "$metadata" | grep -oP '(?<=ndownloads : )[0-9]+')
        function print_result {
            # <OS>-64/<...>.tar.bz2
            pkg_name=$(echo $package | grep -oP '[^/]+/[^/]+.tar.bz2')
            echo "$1;$labels;$ndownloads;$pkg_name" >> $log_file
            echo "[CLEANUP] $1: $pkg_name"
        }

        #make sure the package doesn't have the 'main' label
        if echo "$labels" | grep -P "'main'"
        then
            print_result "On main"
            continue
        fi

        #make sure the package hasn't been downloaded too many times
        if [[ $ndownloads -gt $download_threshold ]]
        then
            print_result "In use"
            continue
        fi

        # The '--force' switch makes package removal non-interactive
        if anaconda -t $ANACONDA_TOKEN remove --force $package
        then
            print_result "Removed"
        else
            # This might be caused by a simultaneously running cleanup script
            print_result "Rm error"
        fi
    done
    end_section
done
