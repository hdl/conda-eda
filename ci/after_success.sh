#!/bin/bash

source $CI_SCRIPTS_PATH/common.sh
set -e

# Close the after_success fold
echo ::endgroup::

if [[ $UPLOAD == "no-upload" ]]; then
    echo "Job without upload..."
else
    echo "Job with Conda upload..."

    $SPACER
    if [ x$ANACONDA_TOKEN != x ]; then
        # `anaconda-client` is installed in the `base` environment
        conda activate base

        start_section "package.upload" "${GREEN}Package uploading...${NC}"
        # Test `anaconda` with ANACONDA_TOKEN before uploading
        source $CI_SCRIPTS_PATH/test_anaconda.sh

        os_package_match='conda-bld/(.*)'
        [[ $CONDA_OUT =~ $os_package_match ]]
        os_and_package="${BASH_REMATCH[1]}"

        name_version_match='conda-bld/(.*)/(.*)-([^-]*)-[^-]*$'
        [[ $CONDA_OUT =~ $name_version_match ]]
        name="${BASH_REMATCH[2]}"
        version="${BASH_REMATCH[3]}"

        check_path="$ANACONDA_USER/$name/$version/$os_and_package"
        branch="$(git rev-parse --abbrev-ref HEAD)"

        if anaconda show $check_path 2>&1 | grep -E "^labels.*'main'"; then
            echo "Package $check_path is present in main label. Uploading will be skipped because doing so would remove the 'main' one."
            if [ "$branch" != "master" ]; then
                exit 1
            fi
        else
            echo "Package $check_path not present in 'main' label"
            anaconda -t $ANACONDA_TOKEN upload --force --no-progress --user $ANACONDA_USER --label ci-$branch-$GITHUB_RUN_ID $CONDA_OUT
        fi

        end_section "package.upload"
    else
        echo "ANACONDA_TOKEN not found. Please consult README of conda-ci for details on setting up tests properly."
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
