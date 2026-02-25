#!/bin/bash

mkdir build 
cd    build 

cmake -D CMAKE_INSTALL_PREFIX=/usr        \
      -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -D BUILD_SHARED_LIBS=ON             \
      -D BUILD_TESTING=ON                 \
      ..        

make
make DESTDIR=$PCKDIR install
