#!/bin/bash

set -x
set -e

CONDA_PATH=${1:-~/conda}

wget -c https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod a+x Miniconda3-latest-Linux-x86_64.sh
if [ ! -d $CONDA_PATH -o ! -z "$CI"  ]; then
        ./Miniconda3-latest-Linux-x86_64.sh -p $CONDA_PATH -b -f
fi
export PATH=$CONDA_PATH/bin:$PATH
conda update -y conda
conda install -y conda-build
conda install -y anaconda-client
conda install -y jinja2
