./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.2
make
make html
make DESTDIR=$PCKDIR install
make DESTDIR=$PCKDIR install-html
