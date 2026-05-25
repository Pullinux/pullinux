
mkdir build &&
cd    build &&

meson setup ..                 \
      --prefix=/usr            \
      --buildtype=release      \
      -D session-managers="[]" &&
ninja

DESTDIR=$PCKDIR ninja install

