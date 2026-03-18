#!/bin/bash

echo "Unmount $1..."

CHRENV=${1:?}

if [ ! -d "$CHRENV" ]; then
    echo "Must supply a valid path for chroot environment"
    exit 1
fi

mountpoint -q $CHRENV/dev/shm && umount $CHRENV/dev/shm
umount $CHRENV/dev/pts
umount $CHRENV/{sys,proc,run,dev}
