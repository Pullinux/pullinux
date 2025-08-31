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

#unmount virtual stuff if already mounted, just to be safe...
plx_umount_virt

plx_mount_virt

build_packages base-system

