#!/bin/bash

set -x
set -e

CONDA_PATH=${1:-~/conda}
if [ $TRAVIS_OS_NAME = 'windows' ]; then
    if [ ! -d $CONDA_PATH -o ! -z "$CI"  ]; then
        choco install openssl.light
        choco install miniconda3 --params="/AddToPath:1"
    fi
    export CONDA_PATH='/c/tools/miniconda3'
    export PATH=$CONDA_PATH/bin/:$CONDA_PATH/Scripts/:$PATH
else
    if [ $TRAVIS_OS_NAME = 'linux' ]; then
        sys_name=Linux
    else
        sys_name=MacOSX
    fi

    wget -c https://repo.continuum.io/miniconda/Miniconda3-latest-${sys_name}-x86_64.sh
    chmod a+x Miniconda3-latest-${sys_name}-x86_64.sh
    if [ ! -d $CONDA_PATH -o ! -z "$CI"  ]; then
            ./Miniconda3-latest-${sys_name}-x86_64.sh -p $CONDA_PATH -b -f
    fi
    export PATH=$CONDA_PATH/bin:$PATH
fi

echo $PATH

conda info

conda config --set safety_checks disabled
conda config --set channel_priority strict
mkdir -p ~/.conda/pkg
conda config --prepend pkgs_dirs ~/.conda/pkg

conda config --show

echo "python==3.7.*" > $CONDA_PATH/conda-meta/pinned
conda install -y python

# `conda` has to be updated before pinning `conda-build`.
# Otherwise it automatically installs `conda-build` which
# is then removed by the `conda update -y --all` -- BUG??
conda update -y conda

# Version has to be both pinned and passed to `conda install`
echo "conda-build==3.20.3" >> $CONDA_PATH/conda-meta/pinned
conda install -y conda-build==3.20.3

conda install -y conda-verify
if [ $TRAVIS_OS_NAME != 'windows' ]; then
    conda install -y ripgrep
fi

conda install -y anaconda-client
conda install -y jinja2

conda update -y --all
