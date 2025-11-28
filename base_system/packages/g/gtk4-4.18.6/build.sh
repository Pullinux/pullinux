sed -e '939 s/= { 0, }//'                                       \
    -e '940 a memset (&transform, 0, sizeof(GtkCssTransform));' \
    -i gtk/gtkcsstransformvalue.c

mkdir __build && cd __build
meson setup --prefix=/usr            \
            --buildtype=release      \
            -D broadway-backend=true \
            -D introspection=enabled \
            -D vulkan=enabled        \
            .. 
ninja
DESTDIR=$PCKDIR ninja install

mkdir -pv $PCKDIR/etc/skel/.config/gtk-4.0
cat > $PCKDIR/etc/skel/.config/gtk-4.0/settings.ini << "EOF"
[Settings]
gtk-theme-name = Adwaita
gtk-icon-theme-name = oxygen
gtk-font-name = DejaVu Sans 12
gtk-cursor-theme-size = 18
gtk-xft-antialias = 1
gtk-xft-hinting = 1
gtk-xft-hintstyle = hintslight
gtk-xft-rgba = rgb
gtk-cursor-theme-name = Adwaita
EOF
