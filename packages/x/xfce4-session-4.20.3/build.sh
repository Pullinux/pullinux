
./configure --prefix=/usr       \
            --sysconfdir=/etc   \
            --disable-legacy-sm 

make

make DESTDIR=$PCKDIR install

