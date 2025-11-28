./configure --prefix=/usr                          \
            --disable-static                       \
            --docdir=/usr/share/doc/libxslt-1.1.43
make
make DESTDIR=$PCKDIR install
