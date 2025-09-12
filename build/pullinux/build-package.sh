#!/bin/bash

PLX="/"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $SRC_DIR/plx-utils.sh
source $SRC_DIR/../shared/utils.sh

SOURCES_DIR=$SRC_DIR/../sources

pck=$1
pck_path=$PCK_ROOT/${pck:0:1}/$pck
version=$(pck_get_version $pck)

build_pck $pck $pck_path $version
