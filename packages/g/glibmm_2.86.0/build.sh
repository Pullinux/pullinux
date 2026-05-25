#!/bin/bash

mkdir bld &&
cd    bld &&

meson setup --prefix=/usr --buildtype=release ..

ninja
DESTDIR=$PCKDIR ninja install
