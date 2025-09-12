mkdir __build && cd __build
cmake -D CMAKE_INSTALL_PREFIX=/usr             \
      -D CMAKE_BUILD_TYPE=Release              \
      -D BUILD_TESTING=OFF                     \
      -D BUILD_SHARED_LIBS=ON                  \
      -D JPEGXL_ENABLE_SKCMS=OFF               \
      -D JPEGXL_ENABLE_SJPEG=OFF               \
      -D JPEGXL_ENABLE_PLUGINS=ON              \
      -D JPEGXL_INSTALL_JARDIR=/usr/share/java \
      -G Ninja ..    
ninja
DESTDIR=$PCKDIR ninja install
