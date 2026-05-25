#!/bin/bash

mkdir build
cd    build

cmake -D CMAKE_INSTALL_PREFIX=$KF6_PREFIX \
        -D CMAKE_INSTALL_LIBEXECDIR=libexec \
        -D CMAKE_BUILD_TYPE=Release         \
        -D BUILD_QT5=OFF                    \
        -D INSTALL_PAM_CONFIGURATION=OFF \
        -D BUILD_TESTING=OFF                \
        -W no-dev ..  

make
make DESTDIR=$PCKDIR install
