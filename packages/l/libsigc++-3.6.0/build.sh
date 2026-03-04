#!/bin/bash

sed -i "s/'system',//" meson.build

mkdir bld &&
cd    bld &&

meson setup --prefix=/usr --buildtype=release ..

ninja
DESTDIR=$PCKDIR ninja install
