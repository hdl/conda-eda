#!/bin/bash

if ! which conda; then
	export PATH=~/conda/bin:$PATH
fi

export  PYTHONWARNINGS=ignore::UserWarning:conda_build.environ

if [ -z "$DATE_STR" ]; then
	export DATE_NUM="$(date -u +%Y%m%d%H%M%S)"
	export DATE_STR="$(date -u +%Y%m%d_%H%M%S)"
	echo "Setting date number to $DATE_NUM"
	echo "Setting date string to $DATE_STR"
fi
if [ -z "$GITREV" ]; then
	export GITREV="$(git describe --long)"
	echo "Setting git revision $GITREV"
fi

export CI=0

export CI_EVENT_TYPE="local"
echo "CI_EVENT_TYPE='${CI_EVENT_TYPE}'"

export CI_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
echo "CI_BRANCH='${CI_BRANCH}'"

export CI_COMMIT="$(git rev-parse HEAD)"
echo "CI_COMMIT='${CI_COMMIT}'"

export CI_REPO_SLUG="$(git rev-parse --abbrev-ref --symbolic-full-name @{u})"
echo "CI_REPO_SLUG='${CI_REPO_SLUG}'"

$GITHUB_WORKSPACE/.github/scripts/conda-meta-extra.sh
echo conda $@
conda $@
