
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.8.1

make
make DESTDIR=$PCKDIR install


#32bit
mkdir -p $PCKDIR/usr/lib32

make distclean
CC="gcc -m32" ./configure \
    --host=i686-pc-linux-gnu      \
    --prefix=/usr                 \
    --libdir=/usr/lib32           \
    --disable-static
make
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
