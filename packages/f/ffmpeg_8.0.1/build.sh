#!/bin/bash

patch -Np1 -i ../ffmpeg-8.0.1-chromium_method-1.patch

sed -e '/adaptive/c\ param->aq_mode = 0;' \
    -i libavcodec/libsvtav1.c

./configure --prefix=/usr        \
            --enable-gpl         \
            --enable-version3    \
            --enable-nonfree     \
            --disable-static     \
            --enable-shared      \
            --disable-debug      \
            --enable-libaom      \
            --enable-libass      \
            --enable-libfdk-aac  \
            --enable-libfreetype \
            --enable-libmp3lame  \
            --enable-libopus     \
            --enable-libvorbis   \
            --enable-libvpx      \
            --enable-libx264     \
            --enable-libx265     \
            --enable-openssl     \
            --enable-libdav1d    \
            --enable-libsvtav1   \
            --ignore-tests=enhanced-flv-av1,enhanced-flv-multitrack \
            --docdir=/usr/share/doc/ffmpeg-8.0.1

make

gcc tools/qt-faststart.c -o tools/qt-faststart

make DESTDIR=$PCKDIR install

mkdir -p $PCKDIR/usr/share/doc/
mkdir -p $PCKDIR/usr/bin

install -v -m755    tools/qt-faststart $PCKDIR/usr/bin 
install -v -m755 -d           $PCKDIR/usr/share/doc/ffmpeg-8.0.1 
install -v -m644    doc/*.txt $PCKDIR/usr/share/doc/ffmpeg-8.0.1
