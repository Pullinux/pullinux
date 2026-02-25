#!/bin/bash

sed -i 's@cert.pem@certs/ca-bundle.crt@' CMakeLists.txt

mkdir build 
cd    build 

echo "Creating cmake... '$QT6DIR'"

cmake -D CMAKE_INSTALL_PREFIX=$QT6DIR            \
      -D CMAKE_BUILD_TYPE=Release                \
      -D QT6=ON                                  \
      -D QCA_INSTALL_IN_QT_PREFIX=ON             \
      -D QCA_MAN_INSTALL_DIR:PATH=/usr/share/man \
      .. 

echo "Starting make..."

echo "Checking lang: $LANG"
echo "Checking LC_ALL: $LC_ALL"


make
make DESTDIR=$PCKDIR install
