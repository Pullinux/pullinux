#!/bin/bash

mkdir -pv /opt/rustc-1.93.1
ln -svfn rustc-1.93.1 /opt/rustc

cat > bootstrap.toml << "EOF" &&
# See bootstrap.toml.example for more possible options,
# and see src/bootstrap/defaults/bootstrap.dist.toml for a few options
# automatically set when building from a release tarball.
# A decent number of options need to be changed.

# Tell x.py that the editors have reviewed the content of this file
# and updated it to follow the major changes of the building system.
# x.py during the build process will warn about it if this is not set.
change-id = 148795

[llvm]
# When using system-installed LLVM, prefer the shared libraries.
link-shared = true

EOF
if [ ! -f /usr/lib32/libc.so.6 ]; then
cat >> bootstrap.toml << "EOF"
# If the shipped LLVM source will be built, only enable the x86 target
# instead of all the targets supported by LLVM.
targets = "X86"

EOF
fi
cat >> bootstrap.toml << "EOF"
[build]
description = "for GLFS #e725a"
EOF
if [ -f /usr/lib32/libc.so.6 ]; then
cat >> bootstrap.toml << "EOF"
target = [
  "x86_64-unknown-linux-gnu",
  "i686-unknown-linux-gnu",
]
EOF
fi &&
cat >> bootstrap.toml << "EOF" &&

# Omit the documentation to save time and space (the default is to build them).
docs = false

# Do not look for new versions of dependencies online.
locked-deps = true

# Specify which extended tools to install.
tools = ["cargo", "clippy", "rustdoc", "rustfmt", "src"]

[install]
prefix = "/opt/rustc-1.93.1"
docdir = "share/doc/rustc-1.93.1"

[rust]
channel = "stable"

# Uncomment if FileCheck has been installed.
#codegen-tests = false

# If you didn't build in NVPTX support, you can uncomment this.
#llvm-bitcode-linker = false

# Enable the same optimizations as the official upstream build.
lto = "thin"
codegen-units = 1

EOF
if [ -f /usr/lib32/libc.so.6 ]; then
cat >> bootstrap.toml << "EOF"
[target.x86_64-unknown-linux-gnu]
cc = "/usr/bin/gcc"
cxx = "/usr/bin/g++"
ar = "/usr/bin/gcc-ar"
ranlib = "/usr/bin/gcc-ranlib"
llvm-config = "/usr/bin/llvm-config"

[target.i686-unknown-linux-gnu]
cc = "/usr/bin/gcc"
cxx = "/usr/bin/g++"
ar = "/usr/bin/gcc-ar"
ranlib = "/usr/bin/gcc-ranlib"
EOF
else
cat >> bootstrap.toml << "EOF"
[target.x86_64-unknown-linux-gnu]
llvm-config = "/usr/bin/llvm-config"

[target.i686-unknown-linux-gnu]
llvm-config = "/usr/bin/llvm-config"
EOF
fi

./x.py build

DESTDIR=$PCKDIR ./x.py install



rm -fv $PCKDIR/opt/rustc-1.93.1/share/doc/rustc-1.93.1/*.old 

install -vDm644 README.md \
  -t $PCKDIR/opt/rustc-1.93.1/share/doc/rustc-1.93.1/

install -vdm755 $PCKDIR/usr/share/zsh/site-functions
ln -sfv /opt/rustc/share/zsh/site-functions/_cargo \
        $PCKDIR/usr/share/zsh/site-functions

mkdir -p $PCKDIR/usr/share/bash-completion/completions

mv -v $PCKDIR/etc/bash_completion.d/cargo \
      $PCKDIR/usr/share/bash-completion/completions

ln -sfv /opt/rustc-1.93.1 $PCKDIR/opt/rustc
