chmod -v 0755 /usr/libexec/file-roller/isoinfo.shc

glib-compile-schemas /usr/share/glib-2.0/schemas

gtk-update-icon-cache -qtf /usr/share/icons/hicolor &&
update-desktop-database -q
