

rchroot() {
    local func="$1"
    shift

    if ! declare -f "$func" > /dev/null; then
        echo "Error: Function '$func' is not defined." >&2
        return 1
    fi

    chroot "$LFS" /usr/bin/env -i MAKEFLAGS="-j $(nproc)" \
                                  HOME=/root \
                                  TERM=xterm \
                                  PATH=/usr/bin:/usr/sbin:/usr/bin:/sbin:/bin \
                                  /usr/bin/bash -l -e -o pipefail -c '
        eval "$1"
        shift
        cd /tmp/build/* || cd /tmp/build
        "$@"
    ' /usr/bin/bash "$(declare -f "$func")" "$func" "$@"
}


build_package() {
    local package="$1"
    local source="$2"
    shift 2

    if grep -qx "$package" installed.txt; then
        return 0
    fi

    mkdir -p /mnt/plx/tmp/build/

    if [ "$source" != "" ]; then

        source_tar=$(basename $source)

        if [ -f "$LFS/sources/$source_tar" ]; then
            echo "Using downloaded tar $source_tar"
        else
            wget $source -P "$LFS/sources/"
        fi

        while [ $# -gt 0 ]; do
            source_file=$(basename $1)

            if [ -f "$LFS/sources/$source_file" ]; then
                echo "Using downloaded file $source_file"
            else
                wget "$1" -P "$LFS/sources/"
            fi

            shift
        done

        tar -xf "$LFS/sources/$source_tar" -C /mnt/plx/tmp/build/
    fi

    rchroot "pck_build_$package"

    rm -rf /mnt/plx/tmp/build/

    echo "$package" >> installed.txt
}

build_package_nontar() {
    local package="$1"
    local source="$2"
    shift 2

    if grep -qx "$package" installed.txt; then
        return 0
    fi

    mkdir -p /mnt/plx/tmp/build/

    if [ "$source" != "" ]; then

        source_tar=$(basename $source)

        if [ -f "$LFS/sources/$source_tar" ]; then
            echo "Using downloaded tar $source_tar"
        else
            wget $source -P "$LFS/sources/"
        fi

        while [ $# -gt 0 ]; do
            source_file=$(basename $1)

            if [ -f "$LFS/sources/$source_file" ]; then
                echo "Using downloaded file $source_file"
            else
                wget "$1" -P "$LFS/sources/"
            fi

            shift
        done
    fi

    rchroot "pck_build_$package"

    rm -rf /mnt/plx/tmp/build/

    echo "$package" >> installed.txt
}

