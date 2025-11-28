sed -i '/LIBPOSTFIX="64"/s/64//' configure.ac 

./autogen.sh              
./configure --prefix=/usr \
            --docdir=/usr/share/doc/graphviz-13.1.2
            

make

make DESTDIR=$PCKDIR install

