#!/bin/bash

./configure --prefix=/usr                   \
            --with-gitconfig=/etc/gitconfig \
            --with-python=python3           \
            --with-libpcre2  

make
make perllibdir=/usr/lib/perl5/5.42/site_perl DESTDIR=$PCKDIR install
