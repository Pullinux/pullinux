
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libogg-1.3.6

make

make DESTDIR=$PCKDIR install

