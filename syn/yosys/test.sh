#!/bin/bash

set -e
set -x

# Identify OS
UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     OS=linux;;
    Darwin*)    OS=osx;;
    *)          OS="${UNAME_OUT}"
                echo "Unknown OS: ${OS}"
                exit;;
esac
echo "Tests started for ${OS}..."

cp $TEST_PACKAGE yosys
cd yosys
tar xvf $TEST_PACKAGE
mv bin/* .
mv share/yosys/* share/
rm -r share/yosys

if [[ $OS == "osx" ]]; then
    # Workaround for broken @rpath
    install_name_tool -add_rpath `pwd`/../../_test_env*/lib yosys
fi

make test
