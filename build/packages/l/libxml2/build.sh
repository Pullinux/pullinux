./configure --prefix=/usr           \
            --sysconfdir=/etc       \
            --disable-static        \
            --with-history          \
            --with-icu              \
            PYTHON=/usr/bin/python3 \
            --docdir=/usr/share/doc/libxml2-2.14.5
make
make DESTDIR=$PCKDIR install

rm -vf $PCKDIR/usr/lib/libxml2.la
sed '/libs=/s/xml2.*/xml2"/' -i $PCKDIR/usr/bin/xml2-config

#32bit
mkdir -p $PCKDIR/usr/lib32
make distclean
CC="gcc -m32" CXX="g++ -m32"         \
PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
./configure --prefix=/usr            \
            --libdir=/usr/lib32      \
            --host=i686-pc-linux-gnu \
            --sysconfdir=/etc        \
            --disable-static         \
            --with-history           \
            --with-icu               \
            --without-python 

make
make DESTDIR=$PWD/DESTDIR install
rm -vf DESTDIR/usr/lib32/libxml2.la   
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32 
rm -rf DESTDIR
ldconfig
