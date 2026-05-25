wget https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-2026.03.03-a4f6003.zip
unzip hytale-launcher-2026.03.03-a4f6003.zip

mkdir -p $PCKDIR/opt/hytale-launcher-bin

cp hytale-launcher $PCKDIR/opt/hytale-launcher-bin/

install -Dm755 ../hytale-launcher.sh $PCKDIR/usr/bin/hytale-launcher
install -Dm644 ../com.hypixel.HytaleLauncher.png "$PCKDIR/usr/share/icons/hicolor/scalable/apps/com.hypixel.HytaleLauncher.png"
install -Dm644 ../com.hypixel.HytaleLauncher.desktop "$PCKDIR/usr/share/applications/com.hypixel.HytaleLauncher.desktop"

