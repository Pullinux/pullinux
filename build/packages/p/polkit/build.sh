
groupadd -fg 27 polkitd || true
useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
        -g polkitd -s /bin/false polkitd || true

mkdir __build && cd __build
meson setup ..                   \
      --prefix=/usr              \
      --buildtype=release        \
      -D os_type=lfs             \
      -D man=false               \
      -D session_tracking=logind \
      -D tests=false
ninja
DESTDIR=$PCKDIR ninja install
