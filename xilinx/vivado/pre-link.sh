#!/bin/bash

# Check if Vivado is present in PATH
LOCAL_VIVADO_VERSION=`vivado -version | sed 's|.*Vivado v\([0-9\.]*\).*|\1|' | sed '1!d'`

if [[ -z $LOCAL_VIVADO_VERSION ]]; then
	# Check if Vivado is present in common installation path
	LOCAL_VIVADO_VERSION=`/opt/Xilinx/Vivado/$PKG_VERSION/bin/vivado -version | sed 's|.*Vivado v\([0-9\.]*\).*|\1|' | sed '1!d'`
	if [[ -z $LOCAL_VIVADO_VERSION ]]; then
		echo "Could not find Vivado ($PKG_VERSION) in neither PATH nor /opt/Xilinx/Vivado/$PKG_VERSION"
		exit 1
	fi
fi

# Check local version against package version
if [[ $PKG_VERSION != $LOCAL_VIVADO_VERSION ]]; then
	echo "Wrong local version of Vivado. Local version is: $LOCAL_VIVADO_VERSION, expected: $PKG_VERSION"
	exit 1
fi
