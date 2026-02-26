#!/bin/bash

./configure --prefix=/usr

make
make DESTDIR=$PCKDIR install
