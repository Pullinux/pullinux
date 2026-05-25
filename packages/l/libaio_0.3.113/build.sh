#!/bin/bash
sed -i '/install.*libaio.a/s/^/#/' src/Makefile

case "$(uname -m)" in
  i?86) sed -e "s/off_t/off64_t/" -i harness/cases/23.t ;;
esac

make
make DESTDIR=$PCKDIR install
