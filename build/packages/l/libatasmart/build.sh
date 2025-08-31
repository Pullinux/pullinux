
./configure --prefix=/usr --disable-static

make

make DESTDIR=$PCKDIR docdir=/usr/share/doc/libatasmart-0.19 install

