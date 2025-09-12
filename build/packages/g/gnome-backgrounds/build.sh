
mkdir build 
cd    build 

meson setup --prefix=/usr ..

DESTDIR=$PCKDIR ninja install

