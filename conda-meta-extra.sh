#!/bin/bash
TOP=$(pwd)
for meta in $(find -name meta.yaml); do
	(
		cd $(dirname $meta);
		ln -sf $(realpath $TOP/recipe_append.yaml --relative-to=.) recipe_append.yaml
	)
done
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
