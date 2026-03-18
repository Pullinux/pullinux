#!/bin/bash

# Copy files from here into an install...

CHRENV=${1:?}

if [ ! -d "$CHRENV" ]; then
    echo "Must supply a valid path for chroot environment"
    exit 1
elif [ "$CHRENV" == "/" ]; then
    CHRENV=""
fi

echo "Copying package data..."

cp -r ../../packages $CHRENV/usr/share/pullinux/

echo "Copying scripts..."

chmod u+x mount-virt.sh
chmod u+x umount-virt.sh

rm $CHRENV/usr/bin/plx-*

mkdir -p $CHRENV/usr/share/pullinux/scripts/
cp -r plx-* $CHRENV/usr/share/pullinux/scripts/
cp mount-virt.sh $CHRENV/usr/share/pullinux/scripts/
cp umount-virt.sh $CHRENV/usr/share/pullinux/scripts/

for f in $CHRENV/usr/share/pullinux/scripts/plx-*
do
    ln -s /usr/share/pullinux/scripts/$(basename $f) $CHRENV/usr/bin/
done;
