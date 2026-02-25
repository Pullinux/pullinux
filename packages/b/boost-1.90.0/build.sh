#!/bin/bash

case $(uname -m) in
   i?86)
      sed -e "s/defined(__MINGW32__)/& || defined(__i386__)/" \
          -i ./libs/stacktrace/src/exception_headers.h ;;
esac

mkdir -p $PCKDIR/usr

./bootstrap.sh --prefix=$PCKDIR/usr --with-python=python3 
./b2 stage -j$(nproc) threading=multi link=shared
./b2 --prefix=$PCKDIR/usr install threading=multi link=shared
