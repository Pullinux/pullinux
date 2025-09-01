#!/bin/bash
set -Eeuo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR=$SRC_DIR/..
SOURCES_DIR=$BUILD_DIR/sources
BACKUP_DIR=$BUILD_DIR/backup

BUILD_USER=$(whoami)

source .config

: ${PLX_DEV:?"PLX Device Not Set"}
: ${PLX:?"PLX Path Not Set"}

source $SRC_DIR/../shared/utils.sh
source $SRC_DIR/plx-utils.sh


create_user_if_none() {
    user=$(awk -F: '$3 == 1000 {print $1, $3}' $PLX/etc/passwd)

    if [ "$user" == "" ]; then
        echo "Setting root password..."

        sudo chroot "$PLX" /usr/bin/env -i   \
            HOME=/root                  \
            PS1='(lfs chroot) \u:\w\$ ' \
            PATH=/usr/bin:/usr/sbin     \
            MAKEFLAGS="-j$(nproc)"      \
            TESTSUITEFLAGS="-j$(nproc)" \
            /bin/bash --login -e -c "passwd root"

        echo "Creating admin user..."

        read -rp "Enter the new username: " username

        if [[ -z "$username" ]]; then
            echo "No username entered, aborting." >&2
            exit -1
        fi

        sudo chroot "$PLX" /usr/bin/env -i   \
            HOME=/root                  \
            PS1='(lfs chroot) \u:\w\$ ' \
            PATH=/usr/bin:/usr/sbin     \
            MAKEFLAGS="-j$(nproc)"      \
            TESTSUITEFLAGS="-j$(nproc)" \
            /bin/bash --login -e -c "useradd -m -G wheel $username; usermod -aG netdev $username || true; passwd $username"

    fi
}

#unmount virtual stuff if already mounted, just to be safe...
plx_umount_virt

plx_mount_virt

build_packages kde-system

create_user_if_none

plx_umount_virt
