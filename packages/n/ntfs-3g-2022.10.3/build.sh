#!/bin/bash

./autogen.sh 

./configure --prefix=/usr        \
            --disable-static     \
            --with-fuse=internal \
            --docdir=/usr/share/doc/ntfs-3g-2022.10.3

make
make DESTDIR=$PCKDIR install
