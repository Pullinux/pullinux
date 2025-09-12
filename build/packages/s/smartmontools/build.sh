
./configure --prefix=/usr           \
            --sysconfdir=/etc       \
            --docdir=/usr/share/doc/smartmontools-7.5
            
make

make DESTDIR=$PCKDIR install

