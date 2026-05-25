#!/bin/bash

patch -Np1 -i ../xorg-server-tearfree_backport-3.patch

mkdir -p build
cd       build

meson setup ..              \
      --prefix=/usr         \
      --localstatedir=/var  \
      -D glamor=true        \
      -D secure-rpc=false   \
      -D xkb_output_dir=/var/lib/xkb

ninja
DESTDIR=$PCKDIR ninja install

mkdir -pv $PCKDIR/etc/X11/xorg.conf.d
