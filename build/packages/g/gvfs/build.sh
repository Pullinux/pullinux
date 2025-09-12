mkdir __build && cd __build
meson setup               \
      --prefix=/usr       \
      --buildtype=release \
      -D onedrive=false   \
      -D fuse=false       \
      -D gphoto2=false    \
      -D afc=false        \
      -D bluray=false     \
      -D nfs=false        \
      -D mtp=false        \
      -D smb=false        \
      -D dnssd=false      \
      -D goa=false        \
      -D google=false     ..
ninja
DESTDIR=$PCKDIR ninja install
