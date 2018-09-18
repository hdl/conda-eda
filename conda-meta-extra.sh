#!/bin/bash
TOP=$(pwd)

cat > recipe_append.yaml <<EOF
extra:
  maintainers:
    - Tim 'mithro' Ansell <mithro@mithis.com>
    - HDMI2USB Project - https://hdmi2usb.tv <hdmi2usb@googlegroups.com>
  travis:
    job_id:  $TRAVIS_JOB_ID
    job_num: $TRAVIS_JOB_NUMBER
    type:    $TRAVIS_EVENT_TYPE
  recipe:
    repo:     'https://github.com/$TRAVIS_REPO_SLUG'
    branch:   $TRAVIS_BRANCH
    commit:   $TRAVIS_COMMIT
    describe: $GITREV
    date:     $DATESTR
EOF
if [ ! -z "${TOOLCHAIN_ARCH}" ]; then
	cat >> recipe_append.yaml <<EOF
  toolchain_arch: ${TOOLCHAIN_ARCH}
EOF
fi

for meta in $(find -name meta.yaml); do
	(
		cd $(dirname $meta);
		ln -sf $(python3 -c "import os.path; print(os.path.relpath('$TOP/recipe_append.yaml'))") recipe_append.yaml
	)
done
