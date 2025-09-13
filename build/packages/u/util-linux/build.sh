./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.41.1
make
make DESTDIR=$PCKDIR install

#32bit
mkdir -p $PCKDIR/usr/lib32
mkdir -p $PCKDIR/usr/bin/

make distclean
mv /usr/bin/ncursesw6-config{,.tmp}
CC="gcc -m32" \
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --host=i686-pc-linux-gnu \
            --libdir=/usr/lib32      \
            --runstatedir=/run       \
            --sbindir=/usr/sbin      \
            --docdir=/usr/share/doc/util-linux-2.41.1 \
            --disable-chfn-chsh      \
            --disable-login          \
            --disable-nologin        \
            --disable-su             \
            --disable-setpriv        \
            --disable-runuser        \
            --disable-pylibmount     \
            --disable-liblastlog2    \
            --disable-static         \
            --without-python

mv /usr/bin/ncursesw6-config{.tmp,}

make
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
