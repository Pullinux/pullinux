mkdir __build && cd __build

cmake -D CMAKE_BUILD_TYPE=Release     \
      -D CMAKE_INSTALL_PREFIX=/usr    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON  \
      -D PORT=GTK                     \
      -D LIB_INSTALL_DIR=/usr/lib     \
      -D USE_LIBBACKTRACE=OFF         \
      -D USE_LIBHYPHEN=OFF            \
      -D ENABLE_GAMEPAD=OFF           \
      -D ENABLE_MINIBROWSER=ON        \
      -D ENABLE_DOCUMENTATION=OFF     \
      -D ENABLE_WEBDRIVER=OFF         \
      -D USE_WOFF2=OFF                \
      -D USE_GTK4=OFF                 \
      -D ENABLE_BUBBLEWRAP_SANDBOX=ON \
      -D USE_SYSPROF_CAPTURE=NO       \
      -D ENABLE_SPEECH_SYNTHESIS=OFF  \
      -W no-dev -G Ninja ..    
ninja
DESTDIR=$PCKDIR ninja install

rm -rf * .[^.]* &&

cmake -D CMAKE_BUILD_TYPE=Release         \
      -D CMAKE_INSTALL_PREFIX=/usr        \
      -D CMAKE_SKIP_INSTALL_RPATH=ON      \
      -D PORT=GTK                         \
      -D LIB_INSTALL_DIR=/usr/lib         \
      -D USE_LIBBACKTRACE=OFF             \
      -D USE_LIBHYPHEN=OFF                \
      -D ENABLE_GAMEPAD=OFF               \
      -D ENABLE_MINIBROWSER=ON            \
      -D ENABLE_DOCUMENTATION=OFF         \
      -D USE_WOFF2=OFF                    \
      -D USE_GTK4=ON                      \
      -D ENABLE_BUBBLEWRAP_SANDBOX=ON     \
      -D USE_SYSPROF_CAPTURE=NO           \
      -D ENABLE_SPEECH_SYNTHESIS=OFF      \
      -W no-dev -G Ninja ..  
ninja
DESTDIR=$PCKDIR ninja install

