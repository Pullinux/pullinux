
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libogg-1.3.6

make

make DESTDIR=$PCKDIR install


#32bit
mkdir -p $PCKDIR/usr/lib32
make distclean
CC="gcc -m32" CXX="g++ -m32"         \
./configure --prefix=/usr            \
            --libdir=/usr/lib32      \
            --host=i686-pc-linux-gnu \
            --disable-static

make
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
