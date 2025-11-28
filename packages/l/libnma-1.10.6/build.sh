mkdir __build && cd __build
meson setup ..            \
      --prefix=/usr       \
      --buildtype=release \
      -D gtk_doc=false    \
      -D libnma_gtk4=true \
      -D mobile_broadband_provider_info=false
ninja
DESTDIR=$PCKDIR ninja install
