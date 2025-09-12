cd AppStream-1.0.6

mkdir -v build 
cd    build 

meson setup --prefix=/usr       \
            --buildtype=release \
            -D apidocs=false    \
            -D stemming=false   .. 
ninja
DESTDIR=$PCKDIR ninja install
