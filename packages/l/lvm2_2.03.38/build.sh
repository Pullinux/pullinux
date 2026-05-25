#!/bin/bash

PATH+=:/usr/sbin                \
./configure --prefix=/usr       \
            --enable-cmdlib     \
            --enable-pkgconfig  \
            --enable-udev_sync

make

make -C tools install_tools_dynamic &&
make -C udev  install               &&
make -C libdm install

make DESTDIR=$PCKDIR install
make DESTDIR=$PCKDIR install_systemd_units
