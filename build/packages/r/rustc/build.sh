
mkdir -pv $PCKDIR/opt/rustc-1.89.0 
ln -svfn rustc-1.89.0 $PCKDIR/opt/rustc

cat << EOF > config.toml
# See bootstrap.toml.example for more possible options,
# and see src/bootstrap/defaults/bootstrap.dist.toml for a few options
# automatically set when building from a release tarball
# (unfortunately, we have to override many of them).

# Tell x.py the editors have reviewed the content of this file
# and updated it to follow the major changes of the building system,
# so x.py will not warn us to do such a review.
change-id = 142379

[llvm]
# When using system llvm prefer shared libraries
link-shared = true

# If building the shipped LLVM source, only enable the x86 target
# instead of all the targets supported by LLVM.
targets = "X86"

[build]
description = "for BLFS 12.4"

# Omit docs to save time and space (default is to build them).
docs = false

# Do not query new versions of dependencies online.
locked-deps = true

# Specify which extended tools (those from the default install).
tools = ["cargo", "clippy", "rustdoc", "rustfmt"]

[install]
prefix = "/opt/rustc-1.89.0"
docdir = "share/doc/rustc-1.89.0"

[rust]
channel = "stable"

# Enable the same optimizations as the official upstream build.
lto = "thin"
codegen-units = 1

# Don't build lld which does not belong to this package and seems not
# so useful for BLFS.  Even if it turns out to be really useful we'd build
# it as a part of the LLVM package instead.
lld = false

# Don't build llvm-bitcode-linker which is only useful for the NVPTX
# backend that we don't enable.
llvm-bitcode-linker = false

[target.x86_64-unknown-linux-gnu]
llvm-config = "/usr/bin/llvm-config"

[target.i686-unknown-linux-gnu]
llvm-config = "/usr/bin/llvm-config"
EOF

sed '/MirOpt/d' -i src/bootstrap/src/core/builder/mod.rs

[ ! -e /usr/include/libssh2.h ] || export LIBSSH2_SYS_USE_PKG_CONFIG=1
[ ! -e /usr/include/sqlite3.h ] || export LIBSQLITE3_SYS_USE_PKG_CONFIG=1

./x.py build

DESTDIR=$PCKDIR ./x.py install

rm -fv $PCKDIR/opt/rustc-1.89.0/share/doc/rustc-1.89.0/*.old   &&
install -vm644 README.md                                \
               $PCKDIR/opt/rustc-1.89.0/share/doc/rustc-1.89.0 &&

install -vdm755 $PCKDIR/usr/share/zsh/site-functions
ln -sfv /opt/rustc/share/zsh/site-functions/_cargo \
        $PCKDIR/usr/share/zsh/site-functions

mkdir -p $PCKDIR/usr/share/bash-completion/completions

mv -v $PCKDIR/etc/bash_completion.d/cargo $PCKDIR/usr/share/bash-completion/completions

mkdir -p $PCKDIR/etc/profile.d

cat > $PCKDIR/etc/profile.d/rustc.sh << "EOF"
# Begin /etc/profile.d/rustc.sh

pathprepend /opt/rustc/bin           PATH

# End /etc/profile.d/rustc.sh
EOF
