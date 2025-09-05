
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libqalculate-5.7.0
make

make DESTDIR=$PCKDIR install

rm -v $PCKDIR/usr/lib/libqalculate.la
