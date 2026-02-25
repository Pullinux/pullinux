url=https://download.kde.org/stable/plasma/6.5.4/
wget -r -nH -nd -A '*.xz' -np $url

cat > plasma-6.5.4.md5 << "EOF"
58f04117211e972efd92f922c96055cd  kdecoration-6.5.4.tar.xz
1f4450689ccc7a9aa20198ac8dc0a6cc  libkscreen-6.5.4.tar.xz
e1be5d31ee907ac0ff175e545b0e0a30  libksysguard-6.5.4.tar.xz
9dbd57f1b956736dd5a9b7a8ea4c3bd1  breeze-6.5.4.tar.xz
59398dd08e6f618172a79090e25f387f  breeze-gtk-6.5.4.tar.xz
7b8cbb35f521ea0fb460c301fc8a9d81  layer-shell-qt-6.5.4.tar.xz
2ae4496598a51f6eaf2a9f5b3c302c77  plasma-activities-6.5.4.tar.xz
27f817a83adcc01813240921a76ab33f  libplasma-6.5.4.tar.xz
38d9e490d8d8208bee2b00c26f88cfef  kscreenlocker-6.5.4.tar.xz
e098b5e2d4c5a7616dbd6240240e5cab  kinfocenter-6.5.4.tar.xz
9af88b31a1c8342ea9e891e628c03626  kglobalacceld-6.5.4.tar.xz
5e1524efe19ca0a22e7c34d3c0042fb0  kwayland-6.5.4.tar.xz
69a421eb481108d2def1f0ccf4137199  aurorae-6.5.4.tar.xz
8777d0ef81794ff04571eae1c2d9dba3  knighttime-6.5.4.tar.xz
68fb57c18349cae5dc411ee8b7e9f654  kwin-x11-6.5.4.tar.xz
1ed01b28a32782eaa10b28bda811c784  kwin-6.5.4.tar.xz
aa362ec117c9a7dfff82ee871aafb75c  plasma5support-6.5.4.tar.xz
cbbda0dbafbd784916e9471c5fc8f6c0  plasma-activities-stats-6.5.4.tar.xz
7b30f4bd2c71d0f54ea1c3b873181323  kpipewire-6.5.4.tar.xz
a488661f1feaf83e86dbdcb964d1b827  plasma-workspace-6.5.4.tar.xz
86ae79614c7be2bcd4529cf86c94b4fc  plasma-disks-6.5.4.tar.xz
49bb09528e33905794b705deff553478  bluedevil-6.5.4.tar.xz
83ecf077f949a86ac8c6e1fd1134f3ea  kde-gtk-config-6.5.4.tar.xz
a852ab4c89356b47e428b8d7fe5711de  kmenuedit-6.5.4.tar.xz
efea3c5c9289680b3bc0028d7b857654  kscreen-6.5.4.tar.xz
3d07bbe0e668bcb30aa377f7b74d2474  kwallet-pam-6.5.4.tar.xz
2e6842536d8a8ff7f069a6dda61d65f6  kwrited-6.5.4.tar.xz
d304d603402df595a00171ec542c51de  milou-6.5.4.tar.xz
633148a8dd396c9afddcc5c8bcea117e  plasma-nm-6.5.4.tar.xz
90e562569589a7ccc9b9da6d8e18801b  plasma-pa-6.5.4.tar.xz
d9d3df0a1c397a9b291e185f676dcbe9  plasma-workspace-wallpapers-6.5.4.tar.xz
cc88a0ecc8daba609245136cb5359f06  polkit-kde-agent-1-6.5.4.tar.xz
147c57031bc1220465d4a6603a535b1c  powerdevil-6.5.4.tar.xz
29bb939ab84528a498b006ca2142a829  plasma-desktop-6.5.4.tar.xz
0ed8da3923d8c044d739f318ecabf05a  kgamma-6.5.4.tar.xz
3d2a784250aa4c782c5126275c5a6b58  ksshaskpass-6.5.4.tar.xz
#3cd4ebe01da73b50f772c2e4e5c518b4  plasma-sdk-6.5.4.tar.xz
767a80aa25321096693eb33a89449132  sddm-kcm-6.5.4.tar.xz
#4e403f30537fb87d942bc6292fa72513  discover-6.5.4.tar.xz
#7ea4c37754e831f2133d778cc3ba024b  breeze-grub-6.5.4.tar.xz
#75b0138b771d2776cf38c15ece7337c2  breeze-plymouth-6.5.4.tar.xz
748b8f9764bd61f0bc89e9bca057f2bc  kactivitymanagerd-6.5.4.tar.xz
0a411ba2ea20803316863915f7a1702d  plasma-integration-6.5.4.tar.xz
#18131058a667fda5bee9d45626fee6d2  plymouth-kcm-6.5.4.tar.xz
aac4e8bbd9d5cdf195488f9c6e13d7e0  xdg-desktop-portal-kde-6.5.4.tar.xz
56c7d0c55024bd43b5c14ff77e374631  drkonqi-6.5.4.tar.xz
5f318f2a7e7284c385ab30940002858d  plasma-vault-6.5.4.tar.xz
#72099f019b5f6835355ed05a15d0040d  plasma-browser-integration-6.5.4.tar.xz
89969215ac1123b112ac9ff325e7bb8a  kde-cli-tools-6.5.4.tar.xz
e1911d223164f6374bc5f24492b02832  systemsettings-6.5.4.tar.xz
f8e8ad0c0c5654abedd734c03b47cd2e  plasma-thunderbolt-6.5.4.tar.xz
#05af2d5b9b5a884698a59a2a6fbdde66  plasma-mobile-6.5.4.tar.xz
#1c265e16027a5fcbe44be6fb2fa63605  plasma-nano-6.5.4.tar.xz
5833d6717d40ef290959e013753cbae2  plasma-firewall-6.5.4.tar.xz
638f11e73f908e0220d4fabee932c9fc  plasma-systemmonitor-6.5.4.tar.xz
2848dcc8f8c7cf188919da3c55e373c9  qqc2-breeze-style-6.5.4.tar.xz
8f1d8564eb8134ecf203a47898a25190  ksystemstats-6.5.4.tar.xz
b4ce7000f5f96ad2d2439a97e632293a  oxygen-sounds-6.5.4.tar.xz
a00742176687fd7eae75084984ef754b  kdeplasma-addons-6.5.4.tar.xz
#76abe3c9f6abf7f68e96b8ee93f5b8b4  flatpak-kcm-6.5.4.tar.xz
1e094cc3ff5b8a056a20bda0fc10dace  plasma-welcome-6.5.4.tar.xz
86b168a0c06a0ba86c94e08bc09e42af  ocean-sound-theme-6.5.4.tar.xz
07df94e19e97f52775d31a35a0ecc60d  print-manager-6.5.4.tar.xz
d95d9304abd61952db9a29a2d8bfbbba  wacomtablet-6.5.4.tar.xz
#47f0fb5bf97ae5662f59ef0340edcc8c  kwayland-integration-6.5.4.tar.xz
#d0711337e89dfd43aec1d30970d2add8  krdp-6.5.4.tar.xz
ab37b5180696761079325fab2c9e269d  oxygen-6.5.4.tar.xz
#78074c45dc269f5593b310c385ca87af  plasma-dialer-6.5.4.tar.xz
#b83bf556dcf693215097d2c3b151aa88  spacebar-6.5.4.tar.xz
1b3e818d9662e3fd65923dc7af4ec273  spectacle-6.5.4.tar.xz
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
        make DESTDIR=$PCKDIR install
        make install
    popd


    rm -rf $packagedir
    /sbin/ldconfig

done < plasma-6.5.4.md5

