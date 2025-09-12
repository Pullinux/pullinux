mkdir -p               $PCKDIR/usr/share/unicode/ucd
unzip -o $PCKBASE/files/UCD.zip -d $PCKDIR/usr/share/unicode/ucd

mkdir -p               /usr/share/unicode/ucd
unzip -o $PCKBASE/files/UCD.zip -d /usr/share/unicode/ucd

sed -e 's@/desktop/ibus@/org/freedesktop/ibus@g' \
    -i data/dconf/org.freedesktop.ibus.gschema.xml

SAVE_DIST_FILES=1 NOCONFIGURE=1 ./autogen.sh &&

PYTHON=python3                     \
./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-python2      \
            --disable-appindicator \
            --disable-gtk2         \
            --disable-emoji-dict

make

make DESTDIR=$PCKDIR install

