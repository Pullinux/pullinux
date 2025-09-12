mkdir __build && cd __build
cmake -D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -D CMAKE_BUILD_TYPE=Release    \
      -D WITH_CAIRO=ON               \
      -D WITH_CLIENT_SDL=OFF         \
      -D WITH_DSP_FFMPEG=ON          \
      -D WITH_FFMPEG=ON              \
      -D WITH_PCSC=OFF               \
      -D WITH_SERVER=ON              \
      -D WITH_SERVER_CHANNELS=ON     \
      -D DOCBOOKXSL_DIR=/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2 \
      -W no-dev                      \
      -G Ninja ..
ninja
DESTDIR=$PCKDIR ninja install
