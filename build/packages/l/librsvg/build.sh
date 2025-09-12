sed -e "/OUTDIR/s|,| / 'librsvg-2.61.0', '--no-namespace-dir',|" \
    -e '/output/s|Rsvg-2.0|librsvg-2.61.0|'                      \
    -i doc/meson.build
    
mkdir __build && cd __build
meson setup --prefix=/usr --buildtype=release ..
ninja
DESTDIR=$PCKDIR ninja install
