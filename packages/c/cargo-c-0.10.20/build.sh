curl -fLO https://github.com/lu-zero/cargo-c/releases/download/v0.10.20/Cargo.lock

export LIBSSH2_SYS_USE_PKG_CONFIG=1    &&
export LIBSQLITE3_SYS_USE_PKG_CONFIG=1 &&

cargo build --release

mkdir -p $PCKDIR/usr/bin/

install -vm755 target/release/cargo-{capi,cbuild,cinstall,ctest} $PCKDIR/usr/bin/
