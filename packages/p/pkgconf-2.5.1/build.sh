./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/pkgconf-2.5.1
make
make DESTDIR=$PCKDIR install

ln -sv pkgconf   $PCKDIR/usr/bin/pkg-config
ln -sv pkgconf.1 $PCKDIR/usr/share/man/man1/pkg-config.1
