#!/bin/bash

if [ $TOOLCHAIN_ARCH != "or1k" ]; then
	echo "Only valid for or1k config."
	exit 1
fi

if [ -z "$PACKAGE" ]; then
	echo "Must provide \$PACKAGE environment variable."
	exit 1
fi

if [ -z "$CONDA_PATH" ]; then
	CONDA_PATH=~/conda/
	export PATH=$CONDA_PATH:$PATH
fi
if ! which conda ; then
	echo "No conda in path?"
	exit 1
fi

TOP_DIR=$PWD
echo "Top dir: $TOP_DIR"
EXTRA_YAML_FILE=$TOP_DIR/$PACKAGE/conda_build_config.$TOOLCHAIN_ARCH.yaml

OR1K_GIT_DIR="$($CONDA_PATH/bin/python $TOP_DIR/find-git-cache.py gcc/nostdc git_url)"
OR1K_GIT_REV="$($CONDA_PATH/bin/python $TOP_DIR/find-git-cache.py gcc/nostdc git_rev)"
if [ -d $OR1K_GIT_DIR ]; then
	echo "OR1K_GIT_DIR: $OR1K_GIT_DIR"
	echo "OR1K_GIT_REV: $OR1K_GIT_REV"
else
	echo "Could not find git directory! ($OR1K_GIT_DIR)"
	exit 1
fi
pushd $OR1K_GIT_DIR >/dev/null

echo "-------------------"
du -h -s .
df -h
echo "-------------------"

git remote -v
if ! git remote -v | grep -q upstream; then
	git remote add upstream git://gcc.gnu.org/git/gcc.git
fi
git fetch upstream
git fetch upstream --tags

git fetch
git fetch --tags

# Find our current or1k release
OR1K_RELEASE=$(git describe --abbrev=0 --match or1k-*-* $OR1K_GIT_REV)
GCC_RELEASE=$(echo $OR1K_RELEASE | sed -e's/^or1k-/gcc-/' -e's/\./_/g' -e's/-[0-9]\+$/-release/')
GCC_RELEASE_FIXED=$(echo $GCC_RELEASE | sed -e's/_/./g')
GCC_GIT_REV=$(git describe --tags --long --match ${GCC_RELEASE} $OR1K_GIT_REV | sed -e"s/^${GCC_RELEASE}-//" -e's/-/_/')

cat > $EXTRA_YAML_FILE <<EOF
or1k_release: $OR1K_RELEASE
gcc_release: $GCC_RELEASE_FIXED
gcc_git_rev: $GCC_GIT_REV
EOF

echo "-------------------"
more $EXTRA_YAML_FILE
echo "-------------------"
du -h -s .
df -h
echo "-------------------"

popd >/dev/null
