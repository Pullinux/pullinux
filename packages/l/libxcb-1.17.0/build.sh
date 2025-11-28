
./configure $XORG_CONFIG      \
            --without-doxygen \
            --docdir='${datadir}'/doc/libxcb-1.17.0 
LC_ALL=en_US.UTF-8 make

make DESTDIR=$PCKDIR install


#32bit
mkdir -p $PCKDIR/usr/lib32
make distclean

CC="gcc -m32" CXX="g++ -m32" PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
./configure $XORG_CONFIG --libdir=/usr/lib32

make
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
