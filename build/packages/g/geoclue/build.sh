mkdir __build && cd __build
meson setup --prefix=/usr       \
            --buildtype=release \
            -D gtk-doc=false    \
            ..     
ninja
DESTDIR=$PCKDIR ninja install

mkdir -p $PCKDIR/etc/geoclue/conf.d/

cat > $PCKDIR/etc/geoclue/conf.d/90-lfs-google.conf << "EOF"
# Begin /etc/geoclue/conf.d/90-lfs-google.conf

# This configuration applies for the WiFi source.
[wifi]

# Set the URL to Google's Geolocation Service.
url=https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyDxKL42zsPjbke5O8_rPVpVrLrJ8aeE9rQ

# End /etc/geoclue/conf.d/90-lfs-google.conf
EOF
