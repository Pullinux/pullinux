mkdir -p /usr/share/gnome-shell/extensions/
mkdir -p /etc/skel/.config/

cp -r dash-to-dock\@micxgx.gmail.com /usr/share/gnome-shell/extensions/
cp -r gtk-4.0 /etc/skel/.config/

mkdir -p /etc/dconf/profile

cat > /etc/dconf/profile/user << EOF
user-db:user
system-db:local
EOF


mkdir -p /etc/dconf/db/local.d/

cat > /etc/dconf/db/local.d/00-extensions << EOF
[org/gnome/shell]
enabled-extensions=['dash-to-dock@micxgx.gmail.com']
favorite-apps=['firefox.desktop', 'org.gnome.Terminal.desktop', 'code.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Calculator.desktop']

[org/gnome/desktop/interface]
color-scheme='prefer-dark'
document-font-name='DejaVu Sans 14'
font-name='DejaVu Sans 14'
monospace-font-name='DejaVu Sans Mono 14'

[org/gnome/settings-daemon/plugins/power]
sleep-inactive-ac-type="nothing"

EOF

dconf update
