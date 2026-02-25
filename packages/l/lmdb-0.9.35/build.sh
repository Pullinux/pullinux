#!/bin/bash

cd libraries/liblmdb 
make                 
sed -i 's| liblmdb.a||' Makefile

make prefix=/usr DESTDIR=$PCKDIR install
