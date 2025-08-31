
./configure --prefix=/usr       \
            --disable-ssh-token \
            --disable-asciidoc 

make

make DESTDIR=$PCKDIR install

