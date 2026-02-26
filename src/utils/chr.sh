#!/bin/bash

set -e

CHRENV=${1:?}

if [ ! -d "$CHRENV" ]; then
    echo "Must supply a valid path for chroot environment"
    exit 1
fi

./mount-virt.sh $CHRENV

chroot "$CHRENV" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(pullinux chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS="-j$(nproc)"      \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash --login

