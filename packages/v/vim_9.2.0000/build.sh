#!/bin/bash

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

./configure --prefix=/usr

make
make DESTDIR=$PCKDIR install

ln -sv vim $PCKDIR/usr/bin/vi
for L in  $PCKDIR/usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

mkdir -p $PCKDIR/usr/share/doc

ln -sv ../vim/vim92/doc $PCKDIR/usr/share/doc/vim-9.2.0000

mkdir -p $PCKDIR/etc/

cat > $PCKDIR/etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF
