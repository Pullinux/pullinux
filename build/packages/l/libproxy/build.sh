mkdir build &&
cd    build 

meson setup ..        \
      --prefix=/usr   \
      -D release=true 

ninja
DESTDIR=$PCKDIR ninja install
