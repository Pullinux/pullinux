./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/enchant-2.8.12 
make
make DESTDIR=$PCKDIR install
