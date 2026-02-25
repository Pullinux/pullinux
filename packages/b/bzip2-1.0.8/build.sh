#!/bin/bash

sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

make -f Makefile-libbz2_so
make clean

make
make PREFIX=$PCKDIR/usr install

mkdir -p $PCKDIR/usr/lib
mkdir -p $PCKDIR/usr/lib32
mkdir -p $PCKDIR/usr/bin

cp -av libbz2.so.* $PCKDIR/usr/lib
ln -sv libbz2.so.1.0.8 $PCKDIR/usr/lib/libbz2.so
ln -sv libbz2.so.1.0.8 $PCKDIR/usr/lib/libbz2.so.1

cp -v bzip2-shared /usr/bin/bzip2
for i in $PCKDIR/usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done

rm -fv $PCKDIR/usr/lib/libbz2.a


#32 bit
make clean
make -f Makefile-libbz2_so clean

sed -e "s/^CC=.*/CC=gcc -m32/" -i Makefile{,-libbz2_so}
make -f Makefile-libbz2_so

install -Dm755 libbz2.so.1.0.8 $PCKDIR/usr/lib32/libbz2.so.1.0.8
ln -sf libbz2.so.1.0.8 $PCKDIR/usr/lib32/libbz2.so
ln -sf libbz2.so.1.0.8 $PCKDIR/usr/lib32/libbz2.so.1
ln -sf libbz2.so.1.0.8 $PCKDIR/usr/lib32/libbz2.so.1.0

