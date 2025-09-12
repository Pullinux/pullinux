mkdir build 
cd    build 

meson setup ..                 \
      --prefix=/usr            \
      --buildtype=release      \
      -D bash_completion=false \
      -D man=false             

ninja

DESTDIR=$PCKDIR ninja install

