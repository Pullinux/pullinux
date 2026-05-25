#!/bin/bash

git clone https://git.sr.ht/~kennylevinsen/seatd
cd seatd

meson setup build/ --prefix=/usr --buildtype=release
ninja -C build/
DESTDIR=$PCKDIR ninja -C build/ install
