./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens
            
make
make DESTDIR=$PCKDIR install

#32bit
mkdir -p $PCKDIR/usr/lib32
mkdir -p $PCKDIR/usr/lib32/pkgconfig

make distclean
CC="gcc -m32" \
./configure --prefix=/usr                \
            --host=i686-pc-linux-gnu     \
            --libdir=/usr/lib32          \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=glibc  \
            --disable-static             \
            --disable-failure-tokens

make

cp -av .libs/libcrypt.so* $PCKDIR/usr/lib32/ &&
make DESTDIR=$PCKDIR install-pkgconfigDATA
ln -svf libxcrypt.pc $PCKDIR/usr/lib32/pkgconfig/libcrypt.pc

