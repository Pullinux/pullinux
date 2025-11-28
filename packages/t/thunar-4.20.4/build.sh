./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/thunar-4.20.4

make

make DESTDIR=$PCKDIR install

