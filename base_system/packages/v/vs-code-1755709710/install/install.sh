ln -s /opt/vs-code/bin/code /usr/bin/code

cp /opt/vs-code/resources/app/resources/linux/code.png /usr/share/icons/hicolor/256x256/apps/

cat > /usr/share/applications/code.desktop << EOF
[Desktop Entry]
Name=Visual Studio Code
Comment=Programming Text Editor
Exec=/opt/vs-code/code %F
Icon=code
Terminal=false
Type=Application
StartupNotify=true
X-KDE-StartupWMClass=Code
Categories=Development;

EOF
