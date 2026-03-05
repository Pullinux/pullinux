#!/bin/bash

patch -Np1 -i ../mitkrb-1.22.2-upstream_fix-1.patch

cd src 
sed -i -e '/eq 0/{N;s/12 //}' plugins/kdb/db2/libdb2/test/run.test 

./configure --prefix=/usr            \
            --sysconfdir=/etc        \
            --localstatedir=/var/lib \
            --runstatedir=/run       \
            --with-system-et         \
            --with-system-ss         \
            --with-system-verto=no   \
            --enable-dns-for-realm   \
            --disable-rpath   

make
make DESTDIR=$PCKDIR install
