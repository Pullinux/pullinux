#!/bin/bash

sed -i 's/gstvideopool.h/video.h/' modules/codec/gstreamer/gstvlcvideopool.h

BUILDCC=gcc ./configure --prefix=/usr --disable-libplacebo 

make
make DESTDIR=$PCKDIR docdir=/usr/share/doc/vlc-3.0.23 install
