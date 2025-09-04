CC='gcc -std=c99' ./configure --prefix=/usr -G -O3 -r
make
make DESTDIR=$PCKDIR install
