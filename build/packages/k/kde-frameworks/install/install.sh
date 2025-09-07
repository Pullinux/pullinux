mv -v /opt/kf6 /opt/kf6-6.17.0
ln -sfvn kf6-6.17.0 /opt/kf6

mkdir -p /etc/dbus-1/
mkdir -p /usr/share/dbus-1 
mkdir -p /usr/share/polkit-1

mv /opt/kf6/etc/dbus-1/* /etc/dbus-1/
mv /opt/kf6/etc/dbus-1/.* /etc/dbus-1/

mv /opt/kf6/share/dbus-1/* /usr/share/dbus-1/
mv /opt/kf6/share/dbus-1/.* /usr/share/dbus-1/

mv /opt/kf6/share/polkit-1/* /usr/share/polkit-1/
mv /opt/kf6/share/polkit-1/.* /usr/share/polkit-1/

mv /opt/kf6/lib/systemd/* /usr/lib/systemd/
mv /opt/kf6/lib/systemd/.* /usr/lib/systemd/

rm -rf /opt/kf6/etc/dbus-1
rm -rf /opt/kf6/share/dbus-1
rm -rf /opt/kf6/share/polkit-1
rm -rf /opt/kf6/lib/systemd

ln -sfv /etc/dbus-1         /opt/kf6/etc         
ln -sfv /usr/share/dbus-1   /opt/kf6/share       
ln -sfv /usr/share/polkit-1 /opt/kf6/share     
ln -sfv /usr/lib/systemd    /opt/kf6/lib
