#!/bin/sh

BUILD_TMP=$BUILD_DIR/build_tmp
SOURCES_DIR=$BUILD_DIR/sources
STATUS_FILE=$BUILD_DIR/.status

SOURCE_RELEASE=https://github.com/Pullinux/pullinux/releases/download/1.0

plx_download_source() {
    package=$1
    dest=$2

    if [ ! -f $dest/$package ]; then
        echo "$dest/$package doesn't exist in $PWD"
        echo "Downloading $1..."
        wget --quiet --show-progress $SOURCE_RELEASE/$1 -P $2/
    fi
}

plx_get_source_path() {
    tarfile=$1

    SP=$(tar -tf $tarfile | awk -F/ 'NR==1 {print $1}')

    if [ "$SP" == "." ]; then
        SP=$(tar -tf $tarfile | awk -F/ 'NR==2 {print $1}')
    fi

    echo "$SP"
}

plx_mount_virt() {

	: "${PLX:?}"

	if ! mountpoint -q "$PLX/dev"; then
		sudo mount -v --bind /dev "$PLX/dev"
	fi

	if ! mountpoint -q "$PLX/dev/pts"; then
		sudo mount -vt devpts devpts -o gid=5,mode=0620 $PLX/dev/pts
	fi

	if ! mountpoint -q "$PLX/proc"; then
		sudo mount -vt proc proc $PLX/proc
	fi

	if ! mountpoint -q "$PLX/sys"; then
            sudo mount -vt sysfs sysfs $PLX/sys
    fi

	if ! mountpoint -q "$PLX/run"; then
            sudo mount -vt tmpfs tmpfs $PLX/run
    fi

	if [ -h $PLX/dev/shm ]; then
	  sudo install -v -d -m 1777 $PLX$(realpath /dev/shm)
  	elif ! mountpoint -q "$PLX/dev/shm"; then
	  sudo mount -vt tmpfs -o nosuid,nodev tmpfs $PLX/dev/shm
	fi

}

plx_umount_virt() {

	: "${PLX:?}"

	sudo mountpoint -q $PLX/dev/shm && sudo umount $PLX/dev/shm

	if mountpoint -q "$PLX/dev/pts"; then
            sudo umount $PLX/dev/pts
    fi

    if mountpoint -q "$PLX/proc"; then
            sudo umount $PLX/proc
    fi

    if mountpoint -q "$PLX/sys"; then
            sudo umount $PLX/sys
    fi

    if mountpoint -q "$PLX/run"; then
            sudo umount $PLX/run
    fi

    if mountpoint -q "$PLX/dev"; then
            sudo umount $PLX/dev
    fi
}
