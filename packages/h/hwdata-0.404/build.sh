#!/bin/bash

./configure --prefix=/usr --disable-blacklist

make DESTDIR=$PCKDIR install
