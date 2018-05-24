# Some colors, use it like following;
# echo -e "Hello ${YELLOW}yellow${NC}"
GRAY='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

SPACER="echo -e ${GRAY} - ${NC}"

export -f travis_nanoseconds
export -f travis_fold
export -f travis_time_start
export -f travis_time_finish
if [ -z "$DATESTR" ]; then
	if [ x"$CONDA_BUILD_VERSION" = x"2.1.17" ]; then
		export DATESTR=$(date -u +%Y%m%d%H%M%S)
		echo "Setting long date string of $DATESTR"
	else
		export DATESTR=$(date -u +%y%m%d%H%M)
		echo "Setting short date string of $DATESTR"
	fi
fi

function start_section() {
	travis_fold start "$1"
	travis_time_start
	echo -e "${PURPLE}${PACKAGE}${NC}: - $2${NC}"
	echo -e "${GRAY}-------------------------------------------------------------------${NC}"
}

function end_section() {
	echo -e "${GRAY}-------------------------------------------------------------------${NC}"
	travis_time_finish
	travis_fold end "$1"
}

# Disable this warning;
# xxxx/conda_build/environ.py:377: UserWarning: The environment variable
#     'TRAVIS' is being passed through with value 0.  If you are splitting
#     build and test phases with --no-test, please ensure that this value is
#     also set similarly at test time.
export PYTHONWARNINGS=ignore::UserWarning:conda_build.environ

export BASE_PATH=/tmp/really-really-really-really-really-really-really-really-really-really-really-really-really-long-path
export CONDA_PATH=$BASE_PATH/conda
mkdir -p $BASE_PATH
export PATH="$PATH:$CONDA_PATH/bin"

export GITREV=$(git describe --long 2>/dev/null || echo "unknown")
export CONDA_OUT=$(conda render $PACKAGE --output 2> /dev/null | tail -n 1 | sed -e's/-[0-9]\+\.tar/*.tar/' -e's/-git//')
