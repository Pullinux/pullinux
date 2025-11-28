rm -v man3/crypt*
make -R GIT=false DESTDIR=$PCKDIR prefix=/usr install

echo "PCKDIR=$PCKDIR"
echo "FILES=$PCKBASE"

ls -ls $PCKBASE
