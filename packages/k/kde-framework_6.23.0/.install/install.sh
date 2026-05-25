pip3 install --no-index --find-links dist --no-user kapidox || echo "kapidox already installed"

mv /opt/kf6{,-6.23.0}
ln -sfv kf6-6.23.0 /opt/kf6
