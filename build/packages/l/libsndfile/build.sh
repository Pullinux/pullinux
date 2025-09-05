sed '/typedef enum/,/bool ;/d' -i \
  src/ALAC/alac_{en,de}coder.c
  
./configure --prefix=/usr     \
            --docdir=/usr/share/doc/libsndfile-1.2.2

make

make DESTDIR=$PCKDIR install

