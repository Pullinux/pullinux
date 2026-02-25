echo "${PLX:?}"

chroot "$PLX" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS="-j$(nproc)"      \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash --login

mountpoint -q $PLX/dev/shm && umount $PLX/dev/shm
umount $PLX/dev/pts
umount $PLX/{sys,proc,run,dev}
