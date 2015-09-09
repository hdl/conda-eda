#!/bin/bash

set -x
set -e

wget -c https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod a+x Miniconda3-latest-Linux-x86_64.sh
if [ ! -d ~/conda ]; then
        ./Miniconda3-latest-Linux-x86_64.sh -p ~/conda -b
fi
export PATH=~/conda/bin:$PATH
conda update conda
conda install -y conda-build
conda install -y anaconda-client
conda install -y jinja2
