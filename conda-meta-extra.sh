#!/bin/bash

PACKAGE=${1:-PACKAGE}
if [ x$PACKAGE = x"" ]; then
	echo "\$PACKAGE not set!"
	exit 1
fi

rm -f $PACKAGE/recipe_append.yaml
cat > $PACKAGE/recipe_append.yaml <<EOF
extra:
  maintainers:
    - Tim 'mithro' Ansell <mithro@mithis.com>
    - HDMI2USB Project - https://hdmi2usb.tv <hdmi2usb@googlegroups.com>
  ci:
    job_id:  $GITHUB_RUN_ID
    job_num: $GITHUB_RUN_NUMBER
    type:    $CI_EVENT_TYPE
  recipe:
    repo:     'https://github.com/$CI_REPO_SLUG'
    branch:   $CI_BRANCH
    commit:   $CI_COMMIT
    describe: $GITREV
    date:     $DATESTR
EOF
if [ ! -z "${TOOLCHAIN_ARCH}" ]; then
	cat >> recipe_append.yaml <<EOF
  toolchain_arch: ${TOOLCHAIN_ARCH}
EOF
fi

if [ -e "$PACKAGE_CONDARC" ]; then
	echo '  condarc:' >> $PACKAGE/recipe_append.yaml
	cat $PACKAGE_CONDARC | sed -e's/^/    /' >> $PACKAGE/recipe_append.yaml
fi
