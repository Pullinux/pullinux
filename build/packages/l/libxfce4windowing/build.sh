
./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --enable-x11      \
            --disable-debug 

make

make DESTDIR=$PCKDIR install

