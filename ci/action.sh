#!/usr/bin/env bash

set -e

# Build
if [ $SKIP ]; then
  exit 0;
fi

if [ $OS_NAME = "windows" ]; then
  export PATH="$PATH:/c/ProgramData/Chocolatey/bin/:/c/Program Files/Git/usr/bin/"
fi

export CI_SCRIPTS_PATH=${CI_SCRIPTS_PATH:-$(dirname "$0")}

source $CI_SCRIPTS_PATH/common.sh

# Download SDK
if [ $OS_NAME = 'osx' ]; then
  if [[ ! -d $HOME/sdk/MacOSX10.9.sdk ]]; then
    git clone https://github.com/phracker/MacOSX-SDKs $HOME/sdk
  fi
fi

bash $CI_SCRIPTS_PATH/install.sh

set -x

if [ $SCRIPT ]; then
  bash $SCRIPT
else
  bash $CI_SCRIPTS_PATH/script.sh
fi

if [ $? -eq 0 ]; then
  source $CI_SCRIPTS_PATH/after_success.sh
else
  source $CI_SCRIPTS_PATH/after_failure.sh
fi
