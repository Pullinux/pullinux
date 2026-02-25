export KF6_PREFIX=/usr

cat >> /etc/profile.d/qt6.sh << "EOF"
# Begin kf6 extension for /etc/profile.d/qt6.sh

pathappend /usr/lib/plugins        QT_PLUGIN_PATH
pathappend $QT6DIR/lib/plugins     QT_PLUGIN_PATH

pathappend /usr/lib/qt6/qml        QML2_IMPORT_PATH
pathappend $QT6DIR/lib/qml         QML2_IMPORT_PATH

#for some reason... LFS doesnt set this up...
pathappend /usr/lib/qml         QML2_IMPORT_PATH

# End extension for /etc/profile.d/qt6.sh
EOF

cat > /etc/profile.d/kf6.sh << "EOF"
# Begin /etc/profile.d/kf6.sh

export KF6_PREFIX=/usr

# End /etc/profile.d/kf6.sh
EOF
