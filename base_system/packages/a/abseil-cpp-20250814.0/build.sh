mkdir __build && cd __build
cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D ABSL_PROPAGATE_CXX_STD=ON \
      -D BUILD_SHARED_LIBS=ON      \
      -G Ninja .. 
ninja
DESTDIR=$PCKDIR ninja install
