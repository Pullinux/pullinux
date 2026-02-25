#!/bin/bash

sed -i 's/char [*]q/const &/' libgomp/affinity-fmt.c

sed -e '/m64=/s/lib64/lib/' \
    -e '/m32=/s/m32=.*/m32=..\/lib32$(call if_multiarch,:i386-linux-gnu)/' \
    -i.orig gcc/config/i386/t-linux64

sed '/STACK_REALIGN_DEFAULT/s/0/(!TARGET_64BIT \&\& TARGET_SSE)/' \
      -i gcc/config/i386/i386.h

mkdir -v build
cd       build

mlist=m64,m32
../configure --prefix=/usr               \
             LD=ld                       \
             --enable-languages=c,c++    \
             --enable-default-pie        \
             --enable-default-ssp        \
             --enable-host-pie           \
             --enable-multilib           \
             --with-multilib-list=$mlist \
             --disable-bootstrap         \
             --disable-fixincludes       \
             --with-system-zlib

make
make DESTDIR=$PCKDIR install

mkdir -p $PCKDIR/usr/lib
mkdir -p $PCKDIR/usr/share/man/man1/
mkdir -p $PCKDIR/usr/lib/bfd-plugins/

ln -svr /usr/bin/cpp $PCKDIR/usr/lib
ln -sv gcc.1 $PCKDIR/usr/share/man/man1/cc.1
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/15.2.0/liblto_plugin.so \
        $PCKDIR/usr/lib/bfd-plugins/

mkdir -pv $PCKDIR/usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py $PCKDIR/usr/share/gdb/auto-load/usr/lib
