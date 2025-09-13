
./configure --sysconfdir=/etc --disable-libav 

make

make DESTDIR=$PCKDIR install


#32bit
mkdir -p $PCKDIR/usr/lib32
make distclean

CC="gcc -m32" CXX="g++ -m32"    \
./configure --libdir=/usr/lib32 \
            --sysconfdir=/etc   \
            --disable-libav     \
            --host=i686-pc-linux-gnu 
            
make
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
