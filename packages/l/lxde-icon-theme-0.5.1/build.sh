#!/bin/bash

./configure --prefix=/usr

make DESTDIR=$PCKDIR install
