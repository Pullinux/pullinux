
cd nspr &&

sed -i '/^RELEASE/s|^|#|' pr/src/misc/Makefile.in &&
sed -i 's|$(LIBRARY) ||'  config/rules.mk         &&

./configure --prefix=/usr   \
            --with-mozilla  \
            --with-pthreads \
            $([ $(uname -m) = x86_64 ] && echo --enable-64bit) 

make

make DESTDIR=$PCKDIR install


#32bit
mkdir -p $PCKDIR/usr/lib32
make distclean

CC="gcc -m32" CXX="g++ -m32"   \
PKG_CONFIG_PATH=/usr/lib32/pkgconfig \
./configure --prefix=/usr            \
            --libdir=/usr/lib32      \
            --host=i686-pc-linux-gnu \
            --with-mozilla           \
            --with-pthreads          \
            --disable-64bit 
make
make DESTDIR=$PWD/DESTDIR install
cp -Rv DESTDIR/usr/lib32/* $PCKDIR/usr/lib32
rm -rf DESTDIR
ldconfig
