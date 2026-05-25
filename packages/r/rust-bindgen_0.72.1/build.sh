#!/bin/bash

cargo build --release

mkdir -p $PCKDIR/usr/bin/

install -vDm755 target/release/bindgen -t $PCKDIR/usr/bin/