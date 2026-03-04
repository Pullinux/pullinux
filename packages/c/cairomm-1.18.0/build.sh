#!/bin/bash

mkdir bld &&
cd    bld &&

meson setup ..             \
      --prefix=/usr        \
      --buildtype=release  \
      -D build-tests=true  \
      -D boost-shared=true
            

ninja
DESTDIR=$PCKDIR ninja install
