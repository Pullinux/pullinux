#!/bin/bash

./configure --prefix=/usr         \
            --libexecdir=/usr/lib \
            --with-secure-path    \
            --with-env-editor     \
            --docdir=/usr/share/doc/sudo-1.9.17p2 \
            --with-passprompt="[sudo] password for %p: " 
make

make DESTDIR=$PCKDIR install
