#!/bin/bash
set -Eeuo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR=$SRC_DIR/..
SOURCES_DIR=$BUILD_DIR/sources
BACKUP_DIR=$BUILD_DIR/backup

BUILD_USER=$(whoami)

export PLX=""

source $SRC_DIR/../shared/utils.sh
source $SRC_DIR/plx-utils.sh

install_packages base-system

install_packages base-dev
install_packages base-ui

install_packages base-kde

install_packages base-ui-extras
