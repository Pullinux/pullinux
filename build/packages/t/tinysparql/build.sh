sed -e "s/'generate'/&, '--no-namespace-dir'/"         \
    -e "/--output-dir/s/@OUTPUT@/&\/tinysparql-3.9.2/" \
    -i docs/reference/meson.build

mkdir __build && cd __build
meson setup --prefix=/usr       \
            --buildtype=release \
            -D man=false        \
            ..     
ninja
DESTDIR=$PCKDIR ninja install
