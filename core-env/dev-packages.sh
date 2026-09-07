
pck_build_cmake() {
    sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake &&

    ./bootstrap --prefix=/usr          \
                --system-libs          \
                --mandir=/share/man    \
                --no-system-jsoncpp    \
                --no-system-cppdap     \
                --no-system-librhash   \
                --no-system-libarchive \
                --no-system-libuv      \
                --docdir=/share/doc/cmake-4.4.2 &&

    make

    make install
}

pck_build_llvm() {
    patch -Np1 -i /sources/llvm-project-22.1.8-upstream_fix-1.patch

    grep -rl '#!.*python$' | xargs sed -i '1s/python$/python3/'

    sed 's/utility/tool/' -i llvm/utils/FileCheck/CMakeLists.txt

    mkdir -pv /etc/clang 
    for i in clang clang++; do
    echo -fstack-protector-strong > /etc/clang/$i.cfg
    done

    mkdir build 
    cd    build 

    CC=gcc CXX=g++                                         \
    cmake -D CMAKE_INSTALL_PREFIX=/usr                     \
        -D CMAKE_SKIP_INSTALL_RPATH=ON                   \
        -D LLVM_ENABLE_FFI=ON                            \
        -D CMAKE_BUILD_TYPE=Release                      \
        -D LLVM_BUILD_LLVM_DYLIB=ON                      \
        -D LLVM_LINK_LLVM_DYLIB=ON                       \
        -D LLVM_ENABLE_RTTI=ON                           \
        -D LLVM_TARGETS_TO_BUILD="X86;host;AMDGPU;NVPTX" \
        -D LLVM_ENABLE_PROJECTS=clang                    \
        -D LLVM_ENABLE_RUNTIMES=compiler-rt              \
        -D LLVM_BINUTILS_INCDIR=/usr/include             \
        -D LLVM_INCLUDE_BENCHMARKS=OFF                   \
        -D CLANG_DEFAULT_PIE_ON_LINUX=ON                 \
        -D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang       \
        -W no-author -G Ninja ../llvm                   

    ninja

    ninja install

    rm -rf * 

    CC=gcc CXX=g++                                          \
    cmake -D CMAKE_INSTALL_PREFIX=/usr                      \
        -D CMAKE_C_FLAGS:STRING=-m32                      \
        -D CMAKE_SKIP_INSTALL_RPATH=ON                    \
        -D CMAKE_CXX_FLAGS:STRING=-m32                    \
        -D LLVM_TARGET_ARCH:STRING=i686                   \
        -D LLVM_LIBDIR_SUFFIX=32                          \
        -D LLVM_ENABLE_FFI=ON                             \
        -D CMAKE_BUILD_TYPE=Release                       \
        -D LLVM_BUILD_LLVM_DYLIB=ON                       \
        -D LLVM_LINK_LLVM_DYLIB=ON                        \
        -D LLVM_ENABLE_RTTI=ON                            \
        -D LLVM_DEFAULT_TARGET_TRIPLE="i686-pc-linux-gnu" \
        -D LLVM_TARGETS_TO_BUILD="X86;host;AMDGPU;NVPTX"  \
        -D LLVM_HOST_TRIPLE="x86_64-pc-linux-gnu"         \
        -D LLVM_ENABLE_PROJECTS=clang                     \
        -D LLVM_ENABLE_RUNTIMES=compiler-rt               \
        -D LLVM_BUILD_UTILS=OFF                           \
        -D LLVM_BUILD_TOOLS=OFF                           \
        -D LLVM_INCLUDE_TESTS=OFF                         \
        -D LLVM_BINUTILS_INCDIR=/usr/include              \
        -D LLVM_INCLUDE_BENCHMARKS=OFF                    \
        -D CLANG_BUILD_TOOLS=OFF                          \
        -D CLANG_DEFAULT_PIE_ON_LINUX=ON                  \
        -D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang        \
        -W no-author -G Ninja ../llvm                    

    ninja

    DESTDIR=$PWD/DESTDIR ninja install    
    cp -vr DESTDIR/usr/lib32/* /usr/lib32 
    rm -rf DESTDIR                        
    ldconfig
}

pck_build_rust() {
    mkdir -pv /opt/rustc-1.97.1 
    ln -svfn rustc-1.97.1 /opt/rustc

cat > bootstrap.toml << "EOF" &&
# See bootstrap.toml.example for more possible options,
# and see src/bootstrap/defaults/bootstrap.dist.toml for a few options
# automatically set when building from a release tarball.
# A decent number of options need to be changed.

# Tell x.py that the editors have reviewed the content of this file
# and updated it to follow the major changes of the building system.
# x.py during the build process will warn about it if this is not set.
change-id = 154587

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
description = "for GLFS 13.1"
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

# Specify which extended tools to install.
tools = ["cargo", "clippy", "rustdoc", "rustfmt", "src"]

[install]
prefix = "/opt/rustc-1.97.1"
docdir = "share/doc/rustc-1.97.1"

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

    ./x.py install

    rm -fv /opt/rustc-1.97.1/share/doc/rustc-1.97.1/*.old   
    install -vDm644 README.md \
    -t /opt/rustc-1.97.1/share/doc/rustc-1.97.1/ 
    install -vdm755 /usr/share/zsh/site-functions 
    ln -sfv /opt/rustc/share/zsh/site-functions/_cargo \
            /usr/share/zsh/site-functions 
    mv -v /etc/bash_completion.d/cargo \
        /usr/share/bash-completion/completions

cat > /etc/profile.d/rustc.sh << "EOF"
# Begin /etc/profile.d/rustc.sh

pathprepend /opt/rustc/bin           PATH

# End /etc/profile.d/rustc.sh
EOF
}



pck_build_cbindgen() {
    cargo build --release
    install -vDm755 target/release/cbindgen -t /usr/bin/
}

pck_build_rbindgen() {
    cargo build --release

    install -vDm755 target/release/bindgen -t /usr/bin/

    bindgen --generate-shell-completions bash \
        > /usr/share/bash-completion/completions/bindgen 
    bindgen --generate-shell-completions zsh  \
        > /usr/share/zsh/site-functions/_bindgen
}

pck_build_mako() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links=dist --no-cache-dir --no-user Mako
}

pck_build_cython() {
    pip3 -v wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links=dist --no-cache-dir --no-user Cython
}

pck_build_libyaml() {
    ./configure --prefix=/usr --disable-static 
    make

    make install
}

pck_build_pyyaml() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links=dist --no-cache-dir --no-user PyYAML
}

pck_build_docutils() {
    for f in /usr/bin/rst*.py; do
    rm -fv /usr/bin/$(basename $f .py)
    done

    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD

    pip3 install --no-index --find-links dist --no-user docutils
}

pck_build_psutil() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links dist --no-user psutil
}

pck_build_pathspec() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links dist --no-user pathspec
}

pck_build_vcs_versioning() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links dist --no-user vcs_versioning
}

pck_build_setuptools_scm() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links dist --no-user setuptools_scm
}

pck_build_pluggy() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links dist --no-user pluggy
}

pck_build_poetry_core() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links dist --no-user poetry-core
}

pck_build_tomlkit() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links dist --no-user tomlkit
}

pck_build_trove_classifiers() {
    sed -i '/calver/s/^/#/;$iversion="2026.6.1.19"' setup.py

    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD

    pip3 install --no-index --find-links dist --no-user trove-classifiers
}

pck_build_hatchling() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links dist --no-user hatchling
}

pck_build_hatch_vcs() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links dist --no-user hatch_vcs
}

pck_build_urllib3() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links dist --no-user urllib3
}

pck_build_semantic_version() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links dist --no-user semantic_version
}

pck_build_setuptools_rust() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD
    pip3 install --no-index --find-links dist --no-user setuptools_rust
}

pck_build_maturin() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD

    pip3 install --no-index --find-links dist --no-user maturin
}

pck_build_uv_build() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD

    pip3 install --no-index --find-links dist --no-user uv_build
}

pck_build_pygments() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD

    pip3 install --no-index --find-links dist --no-user Pygments
}

pck_build_six() {
    pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD

    pip3 install --no-index --find-links dist --no-user six
}

