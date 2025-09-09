mkdir __build && cd __build

meson setup --prefix=/usr .. 

DESTDIR=$PCKDIR ninja install
