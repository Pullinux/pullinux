
PLX_ROOT=/usr/share/plx
PLX_INSTALLED=$PLX_ROOT/installed

PCKDIR=/usr/share/plx/tmp/inst/
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PCK_ROOT="$SRC_DIR/../packages"

VERSION=1.2

LOCAL_INSTALL="no"

pck_installed() {
	sudo touch "$PLX$PLX_INSTALLED"
	grep -Fqx -- "$1" "$PLX$PLX_INSTALLED"
}

pck_get_version() {
	pck=$1
	pck_path=$PCK_ROOT/${pck:0:1}/$pck

	source $pck_path/pck

	echo "$version"
}

pck_get_source() {
	pck=$1
	pck_path=$PCK_ROOT/${pck:0:1}/$pck

	source $pck_path/pck

	echo "$source"
}

chroot_build() {
	sudo mkdir -p $PLX/usr/share/plx/tmp/inst

	sudo touch $PLX/usr/share/plx/tmp/prep.sh

	sudo cp $SRC_DIR/../shared/env.sh $PLX/usr/share/plx/bin/

	sudo chroot "$PLX" /usr/bin/env -i   \
	    HOME=/root                  \
	    PS1='(plx chroot) \u:\w\$ ' \
	    PATH=/usr/bin:/usr/sbin     \
	    MAKEFLAGS="-j$(nproc)"      \
	    TESTSUITEFLAGS="-j$(nproc)" \
	    /bin/bash --login -e -c "cd /usr/share/plx/tmp/ && . /usr/share/plx/bin/env.sh && . /usr/share/plx/tmp/prep.sh && $1"

}

download_extras() {
    base_path=$1

    if [ -f "$base_path/extras.lst" ]; then
        echo "Fetching extra files..."

        for f in $(cat "$base_path/extras.lst")
        do
            plx_download_source $f $SOURCES_DIR
            sudo cp $SOURCES_DIR/$f $base_path/files/
        done;
    fi
}

build_pck() {
	pck=$1
	pck_path=$2
	version=$3
	source=$(pck_get_source $pck)

	echo "Building package $pck $version..."

	#cleanup first...
	sudo rm -rf ${PLX:?}${PLX_ROOT:?}/tmp/$pck
	sudo rm -rf ${PLX:?}${PLX_ROOT:?}/tmp/inst
	sudo mkdir -p ${PLX:?}${PLX_ROOT:?}/tmp/inst
	sudo cp -r $pck_path $PLX$PLX_ROOT/tmp/

	cd $PLX$PLX_ROOT/tmp/$pck

    sudo mkdir -p $PLX$PLX_ROOT/tmp/$pck/files

    download_extras $PLX$PLX_ROOT/tmp/$pck

	echo "export PCKBASE=$PLX_ROOT/tmp/$pck" | sudo tee $PLX/usr/share/plx/tmp/prep.sh > /dev/null
	echo "export PCKDIR=$PLX_ROOT/tmp/inst" | sudo tee -a $PLX/usr/share/plx/tmp/prep.sh > /dev/null
	echo "cd $PLX_ROOT/tmp/$pck" | sudo tee -a $PLX/usr/share/plx/tmp/prep.sh > /dev/null

	if [ "$source" != "" ]; then
        plx_download_source $source $SOURCES_DIR
        sudo cp $SOURCES_DIR/$source files/
		sudo tar -xf files/$source

        SP=$(plx_get_source_path files/$source)

		echo "cd $SP" | sudo tee -a $PLX/usr/share/plx/tmp/prep.sh > /dev/null
	fi

	if [ ! -f build.sh ]; then
		echo "No build file..."
	else
		echo "Running build in chroot..."
		chroot_build "bash -e ../build.sh || bash -e ./build.sh"
	fi

	if [ ! -d install ]; then
		echo "No installer..."
	else
		echo "Copying installer..."
		sudo mkdir -p $PLX$PLX_ROOT/tmp/inst/.install
		sudo cp -r install/* $PLX$PLX_ROOT/tmp/inst/.install/
	fi

	if [ -z "$(ls -A $PLX$PLX_ROOT/tmp/inst)" ]; then
    	echo "No files to package!"
		exit -1
	else
		echo "Creating package $pck-$version-plx-$VERSION.txz..."

		pushd $PLX$PCKDIR
		(
			shopt -s dotglob nullglob
			sudo tar -cJpf $PLX$PLX_ROOT/bin/$pck-$version-plx-$VERSION.txz *
		)
		popd

		sudo cp $PLX$PLX_ROOT/bin/$pck-$version-plx-$VERSION.txz $PLX_ROOT/bin/$pck-$version-plx-$VERSION.txz

		echo "Package build complete for $pck $version"
	fi

	#cleanup last
	sudo rm -rf ${PLX:?}${PLX_ROOT:?}/tmp/$pck
}

install_pck() {
	pck=$1
	version=$2

	sudo rm -rf $PLX/.install

	PLX_BUILD_FILE=$PLX_ROOT/bin/$pck-$version-plx-$VERSION.txz

	echo "Installing $PLX_BUILD_FILE"

	if [ "$PLX" != "/" ]; then
		sudo cp $PLX_BUILD_FILE $PLX$PLX_BUILD_FILE

		sudo chroot "$PLX" /usr/bin/env -i   \
			HOME=/root                  \
			PS1='(plx chroot) \u:\w\$ ' \
			PATH=/usr/bin:/usr/sbin     \
			MAKEFLAGS="-j$(nproc)"      \
			TESTSUITEFLAGS="-j$(nproc)" \
			/bin/bash --login -e -c "cd / && tar -xhf $PLX_BUILD_FILE"

		sudo rm $PLX$PLX_BUILD_FILE
	else
		sudo /bin/bash --login -e -c "cd / && tar -xhf $PLX_BUILD_FILE"
	fi

	if [ -f $PLX/.install/install.sh ]; then
		echo "Running installer..."

		if [ "$PLX" != "/" ]; then
			sudo chroot "$PLX" /usr/bin/env -i   \
				HOME=/root                  \
				PS1='(plx chroot) \u:\w\$ ' \
				PATH=/usr/bin:/usr/sbin     \
				MAKEFLAGS="-j$(nproc)"      \
				TESTSUITEFLAGS="-j$(nproc)" \
				/bin/bash --login -e -c "cd /.install && bash -e install.sh"
		else
			sudo /bin/bash --login -e -c "cd /.install && bash -e install.sh"
		fi

		sudo rm -rf $PLX/.install
	fi

	echo "$pck" | sudo tee -a $PLX$PLX_INSTALLED > /dev/null

	echo "Done installing $pck $version"
}

build_inst_pck() {
	pck=$1
	pck_path=$PCK_ROOT/${pck:0:1}/$pck

	sudo mkdir -p $PLX$PLX_ROOT/tmp/inst
	sudo mkdir -p $PLX_ROOT/bin

	if [ ! -d $pck_path ]; then
		echo "package not found: $pck ($pck_path)"
		exit -1
	fi

	if $(pck_installed $pck) ; then
		echo "Package $pck already installed."
		return 0
	fi

	version=$(pck_get_version $pck)

	if [ ! -f $PLX_ROOT/bin/$pck-$version-plx-$VERSION.txz ]; then
		build_pck $pck $pck_path $version
	else
		echo "Using pre-built package $PLX_ROOT/bin/$pck-$version-plx-$VERSION.txz ..."
	fi

	install_pck $pck $version
}

lpt() {
	echo "$SRC_DIR/$1.lst"
	cat $SRC_DIR/$1.lst
}

load_package_list() {
	pcks=()

    for pck in $(cat $SRC_DIR/$1.lst)
    do
        if [[ $pck =~ ^\! ]]; then
			for incpck in $(load_package_list "${pck:1}")
			do
				pcks+=("$incpck")
			done;
		else
			pcks+=("$pck")
        fi
    done;

    printf '%s\n' "${pcks[@]}"
}

build_packages() {
    for pck in $(load_package_list $1)
    do
        build_inst_pck $pck
    done;
}

local_install_pck() {
	pck=$1
	version=$2

	sudo rm -rf /.install

	PLX_BUILD_FILE=$PLX_ROOT/bin/$pck-$version-plx-$VERSION.txz

	echo "Installing $PLX_BUILD_FILE"

	cd /
	sudo tar -xhf $PLX_BUILD_FILE

	if [ -f /.install/install.sh ]; then
		echo "Running installer..."

		cd /.install
		sudo bash -e install.sh
		sudo rm -rf /.install
	fi

	echo "$pck" | sudo tee -a $PLX_INSTALLED > /dev/null

	echo "Done installing $pck $version"
}

find_install_pck() {
	pck=$1
	pck_path=$PCK_ROOT/${pck:0:1}/$pck

	if [ ! -d $pck_path ]; then
		echo "package not found: $pck ($pck_path)"
		exit -1
	fi

	if $(pck_installed $pck) ; then
		echo "Package $pck already installed."
		return 0
	fi

	version=$(pck_get_version $pck)

	if [ ! -f $PLX_ROOT/bin/$pck-$version-plx-$VERSION.txz ]; then
		echo "Package not build $pck"
		exit -1
	fi

    local_install_pck $pck $version
}

install_packages() {
    for pck in $(load_package_list $1)
    do
        find_install_pck $pck
    done;
}
