#!/bin/bash

mkdir build &&
cd    build &&

meson setup ..        \
      --prefix=/usr   \
      -D release=true -D docs=false

ninja
DESTDIR=$PCKDIR ninja install

rm $PCKDIR/usr/lib/libproxy.a
