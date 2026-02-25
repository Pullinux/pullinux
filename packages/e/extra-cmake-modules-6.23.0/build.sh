#!/bin/bash

sed -i '/"lib64"/s/64//' kde-modules/KDEInstallDirsCommon.cmake &&

sed -e '/PACKAGE_INIT/i set(SAVE_PACKAGE_PREFIX_DIR "${PACKAGE_PREFIX_DIR}")' \
    -e '/^include/a set(PACKAGE_PREFIX_DIR "${SAVE_PACKAGE_PREFIX_DIR}")' \
    -i ECMConfig.cmake.in &&

mkdir build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D BUILD_WITH_QT6=ON         \
      -D DOC_INSTALL_DIR=/usr/share/doc/extra-cmake-modules-6.23.0 \
      ..

make
make DESTDIR=$PCKDIR install
