#!/bin/bash

set -x
set -e

make CC="gcc -I."
make PREFIX=$PREFIX install

git describe | sed -e's/-/_/g' -e's,^debian/0,0,' > ./__conda_version__.txt
touch .buildstamp
TZ=UTC date +%Y%m%d_%H%M%S -r .buildstamp > ../__conda_buildstr__.txt
TZ=UTC date +%Y%m%d%H%M%S  -r .buildstamp > ../__conda_buildnum__.txt
