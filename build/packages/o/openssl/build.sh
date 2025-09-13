./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic
make

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make DESTDIR=$PCKDIR MANSUFFIX=ssl install

mv -v $PCKDIR/usr/share/doc/openssl $PCKDIR/usr/share/doc/openssl-3.5.2

#32bit
mkdir -p $PCKDIR/usr/lib32
make distclean

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib32        \
         shared                \
         zlib-dynamic          \
         linux-x86
         
make
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
