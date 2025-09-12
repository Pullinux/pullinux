gzip -cd $PCKBASE/files/libpng-1.6.47-apng.patch.gz | patch -p1

./configure --prefix=/usr  --disable-static

make

make DESTDIR=$PCKDIR install

