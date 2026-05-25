#!/bin/bash

make EFIDIR=Pullinux EFI_LOADER=grubx64.efi

make DESTDIR=$PCKDIR install EFIDIR=Pullinux
