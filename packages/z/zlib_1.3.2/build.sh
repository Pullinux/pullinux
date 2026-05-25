
./configure --prefix=/usr

make
make DESTDIR=$PCKDIR install

rm -fv $PCKDIR/usr/lib/libz.a


make distclean
CFLAGS+=" -m32" CXXFLAGS+=" -m32" \
./configure --prefix=/usr --libdir=/usr/lib32

make
mkdir -p $PCKDIR/usr/lib32
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
