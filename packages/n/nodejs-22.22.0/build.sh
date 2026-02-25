#!/bin/bash

patch -Np1 -i ../node-v22.22.0-python_build_fix-1.patch

./configure --prefix=/usr          \
            --shared-brotli        \
            --shared-cares         \
            --shared-libuv         \
            --shared-openssl       \
            --shared-nghttp2       \
            --shared-zlib          \
            --with-intl=system-icu 

make
make DESTDIR=$PCKDIR install
