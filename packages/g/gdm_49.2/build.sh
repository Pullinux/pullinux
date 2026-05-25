#!/bin/bash

groupadd -g 21 gdm &&
useradd -c "GDM Daemon Owner" -d /var/lib/gdm -u 21 \
        -g gdm -s /bin/false gdm &&
passwd -ql gdm

mkdir -p build
cd       build

meson setup ..             \
      --prefix=/usr        \
      --buildtype=release  \
      -D gdm-xsession=true \
      -D run-dir=/run/gdm 

ninja
DESTDIR=$PCKDIR ninja install
