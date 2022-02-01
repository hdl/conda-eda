#!/bin/bash
set -ex

LIB=${PKG_NAME#skywater-pdk.}
LIB_DIR=libraries/$LIB/v$PKG_VERSION
mkdir -p $PREFIX/share/skywater-pdk/$LIB_DIR/
(cd $PREFIX/share/skywater-pdk/libraries/$LIB && ln -s v$PKG_VERSION latest)
cp $SRC_DIR/$LIB_DIR/LICENSE $PREFIX/share/skywater-pdk/$LIB_DIR/
cp -r $SRC_DIR/$LIB_DIR/cells $PREFIX/share/skywater-pdk/$LIB_DIR/
if [[ -d $SRC_DIR/$LIB_DIR/models ]]; then
  cp -r $SRC_DIR/$LIB_DIR/models $PREFIX/share/skywater-pdk/$LIB_DIR/
fi
if [[ -d $SRC_DIR/$LIB_DIR/tech ]]; then
  cp -r $SRC_DIR/$LIB_DIR/tech $PREFIX/share/skywater-pdk/$LIB_DIR/
fi
if [[ -d $SRC_DIR/$LIB_DIR/timing ]]; then
  $PYTHON -m skywater_pdk.liberty $LIB_DIR
  $PYTHON -m skywater_pdk.liberty $LIB_DIR all
  $PYTHON -m skywater_pdk.liberty $LIB_DIR all --ccsnoise
  cp -r $SRC_DIR/$LIB_DIR/timing $PREFIX/share/skywater-pdk/$LIB_DIR/
fi
