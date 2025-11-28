mkdir __build && cd __build
cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D AVIF_CODEC_AOM=SYSTEM     \
      -D AVIF_BUILD_GDK_PIXBUF=ON  \
      -D AVIF_LIBYUV=OFF           \
      -G Ninja ..
ninja
DESTDIR=$PCKDIR ninja install
