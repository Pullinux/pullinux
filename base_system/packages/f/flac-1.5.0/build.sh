
./configure --prefix=/usr                                \
            --disable-thorough-tests                     \
            --docdir=/usr/share/doc/flac-1.5.0

make

make DESTDIR=$PCKDIR install


#32bit
mkdir -p $PCKDIR/usr/lib32
make distclean
CC="gcc -m32" CXX="g++ -m32"         \
CFLAGS+=" -L/usr/lib32"              \
CXXFLAGS+=" -L/usr/lib32"            \
./configure --prefix=/usr            \
            --libdir=/usr/lib32      \
            --host=i686-pc-linux-gnu \
            --disable-thorough-tests

make
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
