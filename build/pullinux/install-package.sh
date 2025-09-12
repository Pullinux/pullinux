#!/bin/bash

PLX="/"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $SRC_DIR/plx-utils.sh
source $SRC_DIR/../shared/utils.sh

SOURCES_DIR=$SRC_DIR/../sources

build_inst_pck $1
