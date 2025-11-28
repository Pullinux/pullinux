
./configure --prefix=/usr --disable-static 

make -j1

make DESTDIR=$PCKDIR install

