#!/bin/bash

patch -Np1 -i ../glibc-fhs-1.patch

mkdir -v build
cd       build

echo "rootsbindir=/usr/sbin" > configparms

../configure --prefix=/usr                   \
             --disable-werror                \
             --disable-nscd                  \
             libc_cv_slibdir=/usr/lib        \
             --enable-stack-protector=strong \
             --enable-kernel=5.4

make

touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

make DESTDIR=$PCKDIR install

sed '/RTLDLIST=/s@/usr@@g' -i $PCKDIR/usr/bin/ldd


#32 bit

rm -rf ./*
find .. -name "*.a" -delete

CC="gcc -m32" CXX="g++ -m32"             \
../configure                             \
      --prefix=/usr                      \
      --host=i686-pc-linux-gnu           \
      --build=$(../scripts/config.guess) \
      --libdir=/usr/lib32                \
      --libexecdir=/usr/lib32            \
      --disable-werror                   \
      --disable-nscd                     \
      libc_cv_slibdir=/usr/lib32         \
      --enable-stack-protector=strong    \
      --enable-kernel=5.4

make

mkdir -p $PCKDIR/usr/lib32/
mkdir -p $PCKDIR/usr/include/gnu/
mkdir -p $PCKDIR/etc/

make DESTDIR=$PWD/DESTDIR install
cp -a DESTDIR/usr/lib32/* $PCKDIR/usr/lib32/
install -vm644 DESTDIR/usr/include/gnu/{lib-names,stubs}-32.h \
               $PCKDIR/usr/include/gnu/


cat > $PCKDIR/etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files systemd
group: files systemd
shadow: files systemd

hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

cat > $PCKDIR/etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
/usr/lib32

include /etc/ld.so.conf.d/*.conf

EOF

mkdir -pv $PCKDIR/etc/ld.so.conf.d

