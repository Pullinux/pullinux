sed "/tests_c_args =/s/$/ + ['-U', 'G_DISABLE_ASSERT']/" -i src/tests/meson.build &&
sed "/c_args:/a '-U', 'G_DISABLE_ASSERT'," -i src/tests/cogl/unit/meson.build

mkdir __build && cd __build
meson setup --prefix=/usr            \
            --buildtype=release      \
            -D tests=disabled        \
            -D profiler=false        \
            -D bash_completion=false \
            ..         
ninja
DESTDIR=$PCKDIR ninja install
