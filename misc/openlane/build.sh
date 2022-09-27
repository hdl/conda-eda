#!/bin/bash

set -e
set -x

# Identify OS
UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Linux*)     OS=Linux;;
    *)          OS="${UNAME_OUT}"
                echo "Unknown OS: ${OS}"
                exit;;
esac

mkdir -p $PREFIX/share/openlane
git archive HEAD | tar -xv -C $PREFIX/share/openlane
# define system and pdk variables
mkdir -p $PREFIX/share/openlane/install
cp -a $RECIPE_DIR/env.tcl $PREFIX/share/openlane/install
mkdir -p $PREFIX/share/openlane/install/build/versions
touch $PREFIX/share/openlane/install/build/versions/keep-directory
# override default configuration to disable missing tools
cp -a $RECIPE_DIR/disable-missing-tools.tcl $PREFIX/share/openlane/configuration/disable-missing-tools.tcl
echo -n ' disable-missing-tools.tcl' >> $PREFIX/share/openlane/configuration/load_order.txt
# add flow.tcl shortcut
mkdir -p $PREFIX/bin
cat > $PREFIX/bin/flow.tcl <<EOF
#!/usr/bin/env tclsh
lappend argv "-ignore_mismatches"
source "$::env(CONDA_PREFIX)/share/openlane/flow.tcl"
EOF
chmod +x $PREFIX/bin/flow.tcl
