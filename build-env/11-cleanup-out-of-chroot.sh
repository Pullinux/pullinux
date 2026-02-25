set -e 

echo "${LFS:?}"

mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount $LFS/dev/pts
umount $LFS/{sys,proc,run,dev}

cd $LFS
tar -cJpf /mnt/lfs-temp-tools-ml-12.4-175-systemd.tar.xz .
