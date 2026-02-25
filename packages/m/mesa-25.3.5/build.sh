#!/bin/bash

mkdir -p build
cd       build

meson setup --prefix=/usr            \
            --buildtype=release      \
            -D glvnd=enabled         \
            -D libgbm-external=true  \
            -D platforms=x11,wayland \
            -D gallium-drivers=auto  \
            -D vulkan-drivers=auto   \
            -D video-codecs=all      \
            -D valgrind=disabled     \
            -D libunwind=disabled    \
            ..

ninja
DESTDIR=$PCKDIR ninja install

#32 bit

rm -rf *

meson setup --cross-file=lib32       \
            --prefix=/usr            \
            --libdir=/usr/lib32      \
            --buildtype=release      \
            -D glvnd=enabled         \
            -D libgbm-external=true  \
            -D platforms=x11,wayland \
            -D gallium-drivers=auto  \
            -D vulkan-drivers=auto   \
            -D video-codecs=all      \
            -D valgrind=disabled     \
            -D libunwind=disabled    \
            ..

sed -i 's/\/usr\/lib\//\/usr\/lib32\//g' ./build.ninja

BINDGEN_EXTRA_CLANG_ARGS="-m32" ninja

mkdir -p $PCKDIR/usr/lib32

DESTDIR=$PWD/DESTDIR ninja install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32

if [ -d DESTDIR/usr/share/vulkan ]; then
    mkdir -p $PCKDIR/usr/share
    cp -vR DESTDIR/usr/share/vulkan $PCKDIR/usr/share
fi

rm -rf DESTDIR
