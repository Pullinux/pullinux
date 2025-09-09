mkdir __build && cd __build
cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D SYSCONF_INSTALL_DIR=/etc  \
      -D ENABLE_VALA_BINDINGS=ON   \
      -D ENABLE_INSTALLED_TESTS=ON \
      -D WITH_OPENLDAP=OFF         \
      -D WITH_KRB5=OFF             \
      -D ENABLE_INTROSPECTION=ON   \
      -D ENABLE_GTK_DOC=OFF        \
      -D WITH_LIBDB=OFF            \
      -W no-dev -G Ninja ..  
ninja
DESTDIR=$PCKDIR ninja install
