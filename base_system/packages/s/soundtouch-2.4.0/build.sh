
./bootstrap 
./configure --prefix=/usr \
            --docdir=/usr/share/doc/soundtouch-2.4.0

make

make DESTDIR=$PCKDIR install

