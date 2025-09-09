
cd video/gtk4 &&
cargo build --release

mkdir -p $PCKDIR/usr/lib/gstreamer-1.0
install -vm755 ../../target/release/libgstgtk4.so $PCKDIR/usr/lib/gstreamer-1.0
