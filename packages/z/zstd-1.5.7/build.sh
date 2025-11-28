make prefix=/usr
make prefix=/usr DESTDIR=$PCKDIR install
rm -v $PCKDIR/usr/lib/libzstd.a


#32bit
mkdir -p $PCKDIR/usr/lib32
make clean

CC="gcc -m32" make prefix=/usr

make prefix=/usr DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib/* $PCKDIR/usr/lib32/
sed -e "/^libdir/s/lib$/lib32/" -i $PCKDIR/usr/lib32/pkgconfig/libzstd.pc
rm -rf DESTDIR

