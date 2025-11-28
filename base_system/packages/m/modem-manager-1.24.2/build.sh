
mkdir build 
cd    build 

meson setup ..                 \
      --prefix=/usr            \
      --buildtype=release      \
      -D bash_completion=false \
      -D qrtr=false            
ninja
DESTDIR=$PCKDIR ninja install

