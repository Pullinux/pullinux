mkdir -p /etc/skel/.local/share/gnome-shell/extensions/
cp -r dash-to-dock\@micxgx.gmail.com /etc/skel/.local/share/gnome-shell/extensions/

gnome-extensions enable dash-to-dock@micxgx.gmail.com || echo "Cant enable dash to dock"

gsettings set org.gnome.shell favorite-apps "['firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'code.desktop']" || echo "Cant set favorites"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || echo "Cant set to dark mode"

