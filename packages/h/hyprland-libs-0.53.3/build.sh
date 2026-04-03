
cat > hypr-list << "EOF"
hyprland-protocols/archive/v0.7.0/hyprland-protocols-0.7.0.tar.gz
hyprutils/archive/v0.11.0/hyprutils-0.11.0.tar.gz
hyprlang/archive/v0.6.8/hyprlang-0.6.8.tar.gz
hyprwire/archive/v0.3.0/hyprwire-0.3.0.tar.gz
hyprcursor/archive/v0.1.13/hyprcursor-0.1.13.tar.gz
hyprwayland-scanner/archive/v0.4.5/hyprwayland-scanner-0.4.5.tar.gz
aquamarine/archive/v0.10.0/aquamarine-0.10.0.tar.gz
hyprgraphics/archive/v0.5.0/hyprgraphics-0.5.0.tar.gz
hyprtoolkit/archive/v0.5.3/hyprtoolkit-0.5.3.tar.gz
hyprland-qt-support/archive/v0.1.0/hyprland-qt-support-0.1.0.tar.gz
hyprland-guiutils/archive/v0.2.1/hyprland-guiutils-0.2.1.tar.gz
EOF

mkdir hyprlib &&
cd    hyprlib &&
grep -v '^#' ../hypr-list | wget -i- -c -B https://github.com/hyprwm/

mkdir -p $PCKDIR/etc/profile.d
cat > $PCKDIR/etc/profile.d/hypr.sh << "EOF"
# Begin /etc/profile.d/hypr.sh

pathappend /usr/lib/plugins        QT_PLUGIN_PATH
pathappend $QT6DIR/lib/plugins     QT_PLUGIN_PATH

pathappend /usr/lib/qt6/qml        QML2_IMPORT_PATH
pathappend $QT6DIR/lib/qml         QML2_IMPORT_PATH

# End /etc/profile.d/hypr.sh
EOF

for package in $(grep -v '^#' ../hypr-list)
do
package=$(basename "$package")
packagedir=${package%.tar.?z*}
echo "Building $packagedir"

  tar -xf $package
  pushd $packagedir

  case $packagedir in
    hyprland-protocols-[0-9]* )
      mkdir build
      cd build
        meson setup --prefix=/usr ..
    ;;

    * )
      mkdir build
      cd    build
        cmake -D CMAKE_INSTALL_PREFIX=/usr       \
              -D CMAKE_BUILD_TYPE=Release        \
              -D CMAKE_SKIP_INSTALL_RPATH=ON     \
              -D INSTALL_QML_PREFIX=/lib/qt6/qml \
              -D DISABLE_TESTS=ON                \
              -D BUILD_TESTING=OFF               \
              -W no-dev -G Ninja ..
    ;;
  esac

  ninja
  DESTDIR=$PCKDIR ninja install
  ninja install
  popd
  rm -rf $packagedir
  /sbin/ldconfig
done

