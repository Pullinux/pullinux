mkdir __build && cd __build
cmake -D CMAKE_INSTALL_PREFIX=/usr      \
      -D CMAKE_BUILD_TYPE=Release       \
      -D CMAKE_SKIP_INSTALL_RPATH=ON    \
      -D protobuf_BUILD_TESTS=OFF       \
      -D protobuf_BUILD_SHARED_LIBS=ON  \
      -G Ninja .. 
ninja
DESTDIR=$PCKDIR ninja install
