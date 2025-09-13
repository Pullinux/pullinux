mkdir __build && cd __build
meson setup ..              \
      --prefix=$XORG_PREFIX \
      -D gl_provider=glvnd     \
      --buildtype=release 
ninja
DESTDIR=$PCKDIR ninja install
rm -vf $PCKDIR/usr/lib/libGLU.a || true
