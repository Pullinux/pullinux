sed -i '/merge_file/{n;d}' data/meson.build
mkdir __build && cd __build
meson setup --prefix=/usr --buildtype=release ..
ninja
DESTDIR=$PCKDIR ninja install
