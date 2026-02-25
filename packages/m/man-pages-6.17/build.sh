
rm -v man3/crypt*

make -R GIT=false prefix=/usr DESTDIR=$PCKDIR install

