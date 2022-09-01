#!/bin/bash

set -x
set -e

CONDA_PATH=${1:-~/conda}
if [ $OS_NAME = 'windows' ]; then
    if [ ! -d $CONDA_PATH -o ! -z "$CI"  ]; then
        choco install openssl.light
        choco install miniconda3 --params="/AddToPath:1"
    fi
    export CONDA_PATH='/c/tools/miniconda3'
    export PATH=$CONDA_PATH/bin/:$CONDA_PATH/Scripts/:$PATH
else
    if [ $OS_NAME = 'linux' ]; then
        sys_name=Linux
    else
        sys_name=MacOSX
    fi

    wget --progress=dot:giga -c https://repo.continuum.io/miniconda/Miniconda3-latest-${sys_name}-x86_64.sh
    chmod a+x Miniconda3-latest-${sys_name}-x86_64.sh
    if [ ! -d $CONDA_PATH -o ! -z "$CI"  ]; then
            ./Miniconda3-latest-${sys_name}-x86_64.sh -p $CONDA_PATH -b -f
    fi
    export PATH=$CONDA_PATH/bin:$PATH
fi

echo $PATH

conda info
conda list

echo "python==3.7.*" > $CONDA_PATH/conda-meta/pinned
conda update -y conda
conda install -y anaconda-client
conda install -y python
