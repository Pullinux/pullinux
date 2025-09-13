./configure --prefix=/usr                           \
            --disable-static                        \
            --with-openssl                          \
            --with-ca-path=/etc/ssl/certs
make
make DESTDIR=$PCKDIR install

#32bit
mkdir -p $PCKDIR/usr/lib32
rm -rf * &&
CC="gcc -m32" CXX="g++ -m32"           \
PKG_CONFIG_PATH=/usr/lib32/pkgconfig   \
../configure --prefix=/usr             \
             --libdir=/usr/lib32       \
             --host=i686-pc-linux-gnu  \
             --disable-static          \
             --with-openssl            \
             --with-ca-path=/etc/ssl/certs


make
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
