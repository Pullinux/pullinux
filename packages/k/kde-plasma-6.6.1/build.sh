url=https://download.kde.org/stable/plasma/6.6.1/
wget -r -nH -nd -A '*.xz' -np $url

cat > plasma-6.6.1.md5 << "EOF"
4f409dfbea58c0194bb71342d0ce8f4b  kdecoration-6.6.1.tar.xz
161fb91c028b345ca3cbf2757373b3ab  libkscreen-6.6.1.tar.xz
9c7a297514843a3ddddc13aa47abb5d7  libksysguard-6.6.1.tar.xz
8879fbb3390fefba522a604250b03f3f  breeze-6.6.1.tar.xz
2205ac176646e3ee76f1de2424f6a4ba  breeze-gtk-6.6.1.tar.xz
a1932a163232ba4b04c54edfc69579b7  layer-shell-qt-6.6.1.tar.xz
14342002478d534479956cbc949254b6  plasma-activities-6.6.1.tar.xz
c812ac7dd42ec942ce06a4659d5ac69d  libplasma-6.6.1.tar.xz
9087540a32c4b25658ac59e33244d8ea  kscreenlocker-6.6.1.tar.xz
c1e8c561eba6f967f11ce503dafc9787  kglobalacceld-6.6.1.tar.xz
3528e0b917c4891486b12e6ed1030168  kwayland-6.6.1.tar.xz
ec2badf4cd874cd18ac765a755836338  aurorae-6.6.1.tar.xz
7677ee4d5784931db8c45fd3b48b166f  knighttime-6.6.1.tar.xz
628e60b77b3eab550875de3949aa35f7  plasma-keyboard-6.6.1.tar.xz
291c3b2f46bf450b29efaa802886b86b  kwin-x11-6.6.1.tar.xz
39f4e1ae9dc6a6937c3b3e7072850972  kwin-6.6.1.tar.xz
4a0f39978938484a679e8a882ea10dbd  plasma5support-6.6.1.tar.xz
c1f8d27b30fd7d3a2ad5c06629e2dfa9  plasma-activities-stats-6.6.1.tar.xz
6215a4047975f1aa07f6e31e67f7f2ce  kpipewire-6.6.1.tar.xz
b01b7ab2c6c73bc734e1baf0ac05a1fc  plasma-workspace-6.6.1.tar.xz
99a0f1570f2eb1a556567919aafde24d  plasma-disks-6.6.1.tar.xz
1308b1f70a0c2e576e00bedc149cfc5e  bluedevil-6.6.1.tar.xz
120d5212507410e9e640b2cb4e05b237  kde-gtk-config-6.6.1.tar.xz
5898ecb85449eea4877ca0da8708c57e  kmenuedit-6.6.1.tar.xz
0678fab975f29869dec87ea4a3b5e380  kscreen-6.6.1.tar.xz
2eff25a4f86b5846f45e067dd38de72b  kwallet-pam-6.6.1.tar.xz
3ee17a85d7c6075319da15a9f96a097f  kwrited-6.6.1.tar.xz
92a560fcff81cdf41dd1e002687631bb  milou-6.6.1.tar.xz
b735f04dab4fad80716624dcdf19af63  plasma-nm-6.6.1.tar.xz
c8d4056e3ecff197fd8ce32b7ac3cd33  plasma-pa-6.6.1.tar.xz
16951fa7b52c45599907e28ec39f6c54  plasma-workspace-wallpapers-6.6.1.tar.xz
744e07404850d49d81c1e9b7c24c3cd2  polkit-kde-agent-1-6.6.1.tar.xz
d1a5fc36ebf96509b1b7cbafc6c50db7  powerdevil-6.6.1.tar.xz
4a28478ef792b30c1be1122043334e2e  plasma-desktop-6.6.1.tar.xz
83fc20fc249fafaaff2726e05386f6c0  kgamma-6.6.1.tar.xz
d6df6a2d508082658bbef39f978a0057  ksshaskpass-6.6.1.tar.xz
#6c1b423684c274fe8aa241f744947726  plasma-sdk-6.6.1.tar.xz
2097fac4cc8921235bda91a799c14072  sddm-kcm-6.6.1.tar.xz
#6a838f81134545b07981cd415abf2b43  discover-6.6.1.tar.xz
#3270523c12fc01464f77b2aaabf40df0  breeze-grub-6.6.1.tar.xz
#706690c7a82f4d19b82541545a6e6955  breeze-plymouth-6.6.1.tar.xz
03721c95d72680c04eac7a19fa18c61f  kactivitymanagerd-6.6.1.tar.xz
6e243b4916f19bf21d28179f203fb815  plasma-integration-6.6.1.tar.xz
#45fe33b0cdef10308f87bab81a579f23  plymouth-kcm-6.6.1.tar.xz
27f300c60a131df57e6b9197c124de9e  xdg-desktop-portal-kde-6.6.1.tar.xz
3e33d3646b14a7183d46f2437ac381ca  drkonqi-6.6.1.tar.xz
865cc1c13294a010acb3dea4989b6f97  plasma-vault-6.6.1.tar.xz
#33eb76e30f3b2b8524af88197252d2b0  plasma-browser-integration-6.6.1.tar.xz
9a693af35e8c8344a2c16460dcb56f84  kde-cli-tools-6.6.1.tar.xz
50a59eb8f544c1d60e0327aee273a62b  systemsettings-6.6.1.tar.xz
#33bc395b7c8a9763046156069764f640  plasma-mobile-6.6.1.tar.xz
#ec77afad227127067e0c0f52dca2e212  plasma-nano-6.6.1.tar.xz
cc609934f45af383cc97477b677c5681  plasma-firewall-6.6.1.tar.xz
906d76eee16fcafd6b01c139f9413167  plasma-systemmonitor-6.6.1.tar.xz
9b9269172e245bba8d3c177ac9f47da9  qqc2-breeze-style-6.6.1.tar.xz
32a2d492b1d2b8f8eadd7f1da56e9fc5  ksystemstats-6.6.1.tar.xz
90909df56c06abb57ea3ff86b0ea704a  oxygen-sounds-6.6.1.tar.xz
f0d88d636c596e7f5c00dbf22f6d0d74  kdeplasma-addons-6.6.1.tar.xz
#7336030eef5bd5e8f05190590083f78b  flatpak-kcm-6.6.1.tar.xz
94c59f878c783f9a9423d6c07e5b523e  plasma-welcome-6.6.1.tar.xz
b4f2ab10ef951cbdd272b231e6aa54ab  ocean-sound-theme-6.6.1.tar.xz
ec71ea05a3e2a47207e356df869621b0  print-manager-6.6.1.tar.xz
a6c3248da1dae904438e3adf88a4abec  wacomtablet-6.6.1.tar.xz
#5a25a38d722beaa030a6418a746a9939  kwayland-integration-6.6.1.tar.xz
#1006dcf255da969bb6d09899a67d6c74  krdp-6.6.1.tar.xz
33349b83b2a2415704544ea2300dbee1  oxygen-6.6.1.tar.xz
#0eb4c0b91699d639960d4d2270335522  plasma-dialer-6.6.1.tar.xz
#7a647c072b8b53fae615d3e66380d27b  spacebar-6.6.1.tar.xz
11a7dcf6aec63d51bfba2e40ec669ac6  spectacle-6.6.1.tar.xz
#1c707b638d35a7f4c76536dfc6cc3d1a  plasma-login-manager-6.6.1.tar.xz
859c41b0e80c7b30e91f5f37f9060b0e  plasma-setup-6.6.1.tar.xz
EOF

while read -r line; do

    # Get the file name, ignoring comments and blank lines
    if $(echo $line | grep -E -q '^ *$|^#' ); then continue; fi
    file=$(echo $line | cut -d" " -f2)

    pkg=$(       echo $file|sed 's|^.*/||')    # Remove directory
    name=$(      echo $pkg |sed 's|-6.*$||')   # Isolate package name
    packagedir=$(echo $pkg |sed 's|\.tar.*||') # Source directory

    tar -xf $file
    pushd $packagedir

       mkdir build
       cd    build

       cmake -D CMAKE_INSTALL_PREFIX=$KF6_PREFIX \
             -D CMAKE_INSTALL_LIBEXECDIR=libexec \
             -D CMAKE_BUILD_TYPE=Release         \
             -D BUILD_QT5=OFF                    \
             -D BUILD_TESTING=OFF                \
             -W no-dev ..  &&

        make
        make install
        make DESTDIR=$PCKDIR install
    popd

    rm -rf $packagedir
    /sbin/ldconfig

done < plasma-6.6.1.md5

