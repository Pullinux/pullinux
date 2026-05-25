#!/bin/bash

sed -e '/install -m 644 $(LIBNEWT)/ s/^/#/' \
    -e '/$(LIBNEWT):/,/rv/ s/^/#/'          \
    -e 's/$(LIBNEWT)/$(LIBNEWTSH)/g'        \
    -i Makefile.in                          

./configure --prefix=/usr      \
            --with-gpm-support

make
make DESTDIR=$PCKDIR install
