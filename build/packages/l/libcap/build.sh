sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib
make prefix=/usr lib=lib DESTDIR=$PCKDIR install

#32bit
mkdir -p $PCKDIR/usr/lib32

make distclean


make CC="gcc -m32 -march=i686"
make CC="gcc -m32 -march=i686" lib=lib32 prefix=$PWD/DESTDIR/usr -C libcap install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
sed -e "s|^libdir=.*|libdir=/usr/lib32|" -i $PCKDIR/usr/lib32/pkgconfig/lib{cap,psx}.pc
chmod -v 755 $PCKDIR/usr/lib32/libcap.so.2.76
rm -rf DESTDIR
