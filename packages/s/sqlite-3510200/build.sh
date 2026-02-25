#!/bin/bash

./configure --prefix=/usr     \
            --disable-static  \
            --enable-fts{4,5} \
            CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
                      -D SQLITE_ENABLE_UNLOCK_NOTIFY=1   \
                      -D SQLITE_ENABLE_DBSTAT_VTAB=1     \
                      -D SQLITE_SECURE_DELETE=1"

make LDFLAGS.rpath=""
make DESTDIR=$PCKDIR install


#32 bit

make distclean
CC="gcc -m32" CXX="g++ -m32"         \
./configure --prefix=/usr            \
            --libdir=/usr/lib32      \
            --host=i686-pc-linux-gnu \
            --disable-static         \
            --enable-fts{4,5}        \
            CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
                      -D SQLITE_ENABLE_UNLOCK_NOTIFY=1   \
                      -D SQLITE_ENABLE_DBSTAT_VTAB=1     \
                      -D SQLITE_SECURE_DELETE=1"

make LDFLAGS.rpath=""
mkdir -p $PCKDIR/usr/lib32
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
