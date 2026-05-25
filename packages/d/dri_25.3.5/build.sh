

install -vDm644 include/GL/internal/dri_interface.h \
        -t      $PCKDIR/usr/include/GL/internal/          
install -vDm644 include/EGL/eglmesaext.h            \
        -t      $PCKDIR/usr/include/EGL/                  
install -vDm644 include/EGL/eglext_angle.h          \
        -t      $PCKDIR/usr/include/EGL/

cat > dri.pc << "EOF"
prefix=/usr
includedir=${prefix}/include

dridriverdir=${prefix}/lib/dri

Name: dri
Description: Direct Rendering Infrastructure
Version: MESA_VERSION
Requires.private: libdrm >=  2.4.109
Cflags: -I${includedir}
EOF

mkdir -p $PCKDIR/usr/lib/pkgconfig/

sed -i "s/MESA_VERSION/`cat VERSION`/" dri.pc 
install -vDm644 dri.pc -t $PCKDIR/usr/lib/pkgconfig/ 
rm -vf dri.pc

