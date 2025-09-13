./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy
make

make DESTDIR=$PCKDIR -C libelf install

mkdir -p $PCKDIR/usr/lib/pkgconfig

install -vm644 config/libelf.pc $PCKDIR/usr/lib/pkgconfig
rm $PCKDIR/usr/lib/libelf.a

#32bit
mkdir -p $PCKDIR/usr/lib32
make distclean
CC="gcc -m32" CXX="g++ -m32" ./configure \
    --host=i686-pc-linux-gnu \
    --prefix=/usr            \
    --libdir=/usr/lib32      \
    --disable-debuginfod     \
    --enable-libdebuginfod=dummy

make
make DESTDIR=$PWD/DESTDIR -C libelf install
install -vDm644 config/libelf.pc DESTDIR/usr/lib32/pkgconfig/libelf.pc
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
