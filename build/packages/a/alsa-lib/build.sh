sed 's/playmidi1//' -i test/Makefile.am 
autoreconf -fi
./configure 
make
make DESTDIR=$PCKDIR install

tar -C $PCKDIR/usr/share/alsa --strip-components=1 -xf $PCKBASE/files/alsa-ucm-conf-1.2.14.tar.bz2

