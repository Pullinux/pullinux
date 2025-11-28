sed -e 's/def __cplusplus/ defined(__cplusplus) || __STDC_VERSION__ >= 202311L/' \
    -i libyasm/bitvect.h

sed -i 's#) ytasm.*#)#' Makefile.in
./configure --prefix=/usr 

make

make DESTDIR=$PCKDIR install
