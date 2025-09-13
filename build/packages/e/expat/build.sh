./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.7.1
make
make DESTDIR=$PCKDIR install

#32bit
sed -e "/^am__append_1/ s/doc//" -i Makefile
mkdir -p $PCKDIR/usr/lib32
make clean

CC="gcc -m32" ./configure \
    --prefix=/usr        \
    --disable-static     \
    --libdir=/usr/lib32  \
    --host=i686-pc-linux-gnu

make
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
