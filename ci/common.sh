# Some colors, use it like following;
# echo -e "Hello ${YELLOW}yellow${NC}"
GRAY=' \033[0;30m'
RED=' \033[0;31m'
GREEN=' \033[0;32m'
YELLOW=' \033[0;33m'
PURPLE=' \033[0;35m'
NC='\033[0m' # No Color

SPACER="echo -e ${GRAY} - ${NC}"

CI_MAX_TIME=50

ci_wait() {
	local timeout="${1}"

	if [[ "${timeout}" =~ ^[0-9]+$ ]]; then
		shift
	else
		timeout=20
	fi

	local cmd=("${@}")
	local log_file="ci_wait_${$}.log"

	"${cmd[@]}" &
	local cmd_pid="${!}"

	ci_jigger "${!}" "${timeout}" "${cmd[@]}" &
	local jigger_pid="${!}"
	local result

	{
		wait "${cmd_pid}" 2>/dev/null
		result="${?}"
		ps -p"${jigger_pid}" &>/dev/null && kill "${jigger_pid}"
	}

	if [[ "${result}" -eq 0 ]]; then
		printf "\\n${ANSI_GREEN}The command %s exited with ${result}.${ANSI_RESET}\\n" "${cmd[*]}"
	else
		printf "\\n${ANSI_RED}The command %s exited with ${result}.${ANSI_RESET}\\n" "${cmd[*]}"
	fi

	echo -e "\\n${ANSI_GREEN}Log:${ANSI_RESET}\\n"

	return "${result}"
}

ci_jigger() {
	local cmd_pid="${1}"
	shift
	local timeout="${1}"
	shift
	local count=0

	echo -e "\\n"

	while [[ "${count}" -lt "${timeout}" ]]; do
		count="$((count + 1))"
		# print invisible character
		echo -ne "\xE2\x80\x8B"
		sleep 60
	done

	echo -e "\\n${ANSI_RED}Timeout (${timeout} minutes) reached. Terminating \"${*}\"${ANSI_RESET}\\n"
	kill -9 "${cmd_pid}"
}

if [ $OS_NAME = 'osx' ]; then
    export DATE_SWITCH="-r "
else
    export DATE_SWITCH="--date=@"
fi
if [ -z "$DATE_STR" ]; then
	export DATE_TS="$(git log --format=%ct -n1)"
	export DATE_NUM="$(date ${DATE_SWITCH}${DATE_TS} -u +%Y%m%d%H%M%S)"
	export DATE_STR="$(date ${DATE_SWITCH}${DATE_TS} -u +%Y%m%d_%H%M%S)"
	echo "Setting date number to $DATE_NUM"
	echo "Setting date string to $DATE_STR"
fi

function start_section() {
	echo "::group::$1"
	echo -e "${PURPLE}${PACKAGE}${NC}: - $2${NC}"
	echo -e "${GRAY}-------------------------------------------------------------------${NC}"
}

function end_section() {
	echo -e "${GRAY}-------------------------------------------------------------------${NC}"
	echo "::endgroup::"
}

export PYTHONWARNINGS=ignore::UserWarning:conda_build.environ

export BASE_PATH="/tmp/really-long-path"
mkdir -p "$BASE_PATH"
if [ $OS_NAME = 'windows' ]; then
    export CONDA_PATH='/c/tools/miniconda3'
    export PATH=$CONDA_PATH/Scripts/:$CONDA_PATH/:$PATH

    # It is much shorter than '$PWD/workdir/conda-env' which in the end (+conda-bld/...)
    # causes some build paths to exceed 255 chars (e.g. during prjtrellis building)
    RUNNER_DIR='/c/Users/runner/'
    if [ ! -d "$RUNNER_DIR" ]; then
    	mkdir "$RUNNER_DIR"
    fi

    export CONDA_ENV="$RUNNER_DIR/conda-env"
    if [ -d 'workdir/conda-env' ]; then
        mv 'workdir/conda-env' "$CONDA_ENV"
    fi
else
    export CONDA_PATH="$BASE_PATH/conda"
    export PATH="$CONDA_PATH/bin:$PATH"
    export CONDA_ENV='workdir/conda-env'
fi

if [ -d "$CONDA_ENV" ] && which conda &>/dev/null; then
    # >>> conda initialize >>>
    eval "$('conda' 'shell.bash' 'hook' 2> /dev/null)"
    # <<< conda initialize <<<

    conda activate "$CONDA_ENV"
fi

export GIT_SSL_NO_VERIFY=1
export GITREV="$(git describe --long 2>/dev/null || echo "unknown")"

# 'workdir/recipe' contains $PACKAGE recipe prepared by conda-build-prepare
if [ -d "workdir/recipe" ]; then
    export CONDA_BUILD_ARGS="$EXTRA_BUILD_ARGS workdir/recipe"
    export CONDA_OUT="$(conda render --output $CONDA_BUILD_ARGS | grep conda-bld | grep tar.bz2 | tail -n 1 | sed -e's/-[0-9]\+\.tar/*.tar/' -e's/-git//')"

    if [ "$OS_NAME" = 'windows' ]; then
        # conda render outputs Windows-style path which may contain wildcards;
        export CONDA_OUT="$(cygpath -u $CONDA_OUT)"
    fi
fi

echo "          GITREV: $GITREV"
echo "      CONDA_PATH: $CONDA_PATH"
echo "CONDA_BUILD_ARGS: $CONDA_BUILD_ARGS"
echo "       CONDA_OUT: $CONDA_OUT"
