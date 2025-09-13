./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native
            
make
make DESTDIR=$PCKDIR install

#32bit
mkdir -p $PCKDIR/usr/lib32
make distclean

CC="gcc -m32" CXX="g++ -m32" ./configure \
    --host=i686-pc-linux-gnu \
    --prefix=/usr            \
    --libdir=/usr/lib32      \
    --disable-static         \
    --with-gcc-arch=i686
    
make
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
