patch -Np1 -i $PCKBASE/files/libportal-0.9.1-qt6.9_fixes-1.patch


mkdir __build && cd __build
meson setup --prefix=/usr       \
            --buildtype=release \
            -D vapi=false       \
            -D docs=false       \
            ..
ninja
DESTDIR=$PCKDIR ninja install
