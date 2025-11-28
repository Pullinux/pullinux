sed -i -r 's:"(/system):"/org/gnome\1:g' src/external.gschema.xml

mkdir __build && cd __build
meson setup --prefix=/usr --buildtype=release ..
ninja
DESTDIR=$PCKDIR ninja install
