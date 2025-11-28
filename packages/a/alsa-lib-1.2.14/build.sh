
./configure 
make
make DESTDIR=$PCKDIR install

tar -C $PCKDIR/usr/share/alsa --strip-components=1 -xf $PCKBASE/files/alsa-ucm-conf-1.2.14.tar.bz2


#32bit
mkdir -p $PCKDIR/usr/lib32
make distclean
CC="gcc -m32" CXX="g++ -m32"         \
./configure --libdir=/usr/lib32      \
            --host=i686-pc-linux-gnu 

make
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
