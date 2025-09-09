mkdir __build && cd __build
cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D BUILD_TESTING=OFF         \
      -D BUILD_SHARED_LIBS=ON      \
      -G Ninja ..
ninja
DESTDIR=$PCKDIR ninja install
