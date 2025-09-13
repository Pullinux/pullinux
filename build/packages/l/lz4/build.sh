make BUILD_STATIC=no PREFIX=/usr
make DESTDIR=$PCKDIR BUILD_STATIC=no PREFIX=/usr install

#32bit
mkdir -p $PCKDIR/usr/lib32
make clean

CC="gcc -m32" make BUILD_STATIC=no

make BUILD_STATIC=no PREFIX=/usr LIBDIR=/usr/lib32 DESTDIR=$(pwd)/m32 install
cp -a m32/usr/lib32/* $PCKDIR/usr/lib32/
