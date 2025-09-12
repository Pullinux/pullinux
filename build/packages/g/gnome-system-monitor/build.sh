find . -name meson.build | xargs sed -i -e '/catch2/d' &&
sed -i '152,162d' src/meson.build

mkdir __build && cd __build
meson setup --prefix=/usr --buildtype=release ..
ninja
DESTDIR=$PCKDIR ninja install
