groupadd -g 21 gdm || true
useradd -c "GDM Daemon Owner" -d /var/lib/gdm -u 21 \
        -g gdm -s /bin/false gdm || true
passwd -ql gdm || true

sed -r 's/([(*])bool([) ])/\1boolval\2/' -i common/gdm-settings-utils.*

mkdir __build && cd __build
meson setup ..             \
      --prefix=/usr        \
      --buildtype=release  \
      -D gdm-xsession=true \
      -D run-dir=/run/gdm
ninja
DESTDIR=$PCKDIR ninja install
