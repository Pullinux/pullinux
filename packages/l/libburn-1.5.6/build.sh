#!/bin/bash

sed -i 's/catch_int ()/catch_int (int signum)/' test/poll.c

./configure --prefix=/usr --disable-static

make
make DESTDIR=$PCKDIR install
