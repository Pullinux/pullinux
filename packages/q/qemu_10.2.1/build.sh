#!/bin/bash

QEMU_ARCH=x86_64-softmmu

mkdir -vp build &&
cd        build &&

../configure --prefix=/usr            \
             --sysconfdir=/etc        \
             --localstatedir=/var     \
             --target-list=$QEMU_ARCH \
             --audio-drv-list=alsa    \
             --disable-pa             \
             --enable-slirp           \
             --docdir=/usr/share/doc/qemu-10.2.1 

unset QEMU_ARCH 

make
make DESTDIR=$PCKDIR install

