patch -Np1 -i $PCKBASE/files/libtirpc-1.3.6-gcc15_fixes-1.patch

./configure --prefix=/usr                                    \
            --sysconfdir=/etc                               \
            --disable-static                                \
            --disable-gssapi 

make

make DESTDIR=$PCKDIR install

