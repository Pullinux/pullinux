sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake

./bootstrap --prefix=/usr          \
            --system-libs          \
            --mandir=/share/man    \
            --no-system-jsoncpp    \
            --no-system-cppdap     \
            --no-system-librhash   \
            --no-system-libarchive \
            --no-system-libuv      \
            --no-system-nghttp2    \
            --docdir=/share/doc/cmake-4.1.0
make
make DESTDIR=$PCKDIR install
