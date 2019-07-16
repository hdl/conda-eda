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

#echo "python==3.7" > $CONDA_PATH/conda-meta/pinned
#echo "conda-build==3.14.0" >> $CONDA_PATH/conda-meta/pinned

conda install -y python
conda update -y conda

conda install -y conda-build
conda install -y conda-verify

conda install -y anaconda-client
conda install -y jinja2

conda update -y --all
