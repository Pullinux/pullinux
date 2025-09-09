sed -i "/GPGME_EVENT_NEXT_TRUSTITEM/d" pgp/seahorse-gpgme.c

sed -i -r 's:"(/apps):"/org/gnome\1:' data/*.xml

mkdir __build && cd __build
meson setup --prefix=/usr --buildtype=release ..
ninja
DESTDIR=$PCKDIR ninja install
