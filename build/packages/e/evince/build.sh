mkdir __build && cd __build
CPPFLAGS+=" -I/opt/texlive/2025/include -DNO_DEBUG" \
meson setup --prefix=/usr                \
            --buildtype=release          \
            -D gtk_doc=false             \
            --wrap-mode=nodownload       \
            ..  
ninja
DESTDIR=$PCKDIR ninja install
