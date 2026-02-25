echo "${PLX:?}"

mount -v --bind /dev $PLX/dev
mount -vt devpts devpts -o gid=5,mode=0620 $PLX/dev/pts
mount -vt proc proc $PLX/proc
mount -vt sysfs sysfs $PLX/sys
mount -vt tmpfs tmpfs $PLX/run

if [ -h $PLX/dev/shm ]; then
  install -v -d -m 1777 $PLX$(realpath /dev/shm)
else
  mount -vt tmpfs -o nosuid,nodev tmpfs $PLX/dev/shm
fi

