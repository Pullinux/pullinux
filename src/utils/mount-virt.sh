#!/bin/bash

CHRENV=${1:?}

if [ ! -d "$CHRENV" ]; then
    echo "Must supply a valid path for chroot environment"
    exit 1
fi

function mountbind
{
   if ! mountpoint $CHRENV/$1 >/dev/null; then
     mount --bind /$1 $CHRENV/$1
     echo $CHRENV/$1 mounted
   else
     echo $CHRENV/$1 already mounted
   fi
}

function mounttype
{
   if ! mountpoint $CHRENV/$1 >/dev/null; then
     mount -t $2 $3 $4 $5 $CHRENV/$1
     echo $CHRENV/$1 mounted
   else
     echo $CHRENV/$1 already mounted
   fi
}

mountbind dev
mounttype dev/pts devpts devpts -o gid=5,mode=620
mounttype proc    proc   proc
mounttype sys     sysfs  sysfs
mounttype run     tmpfs  run
if [ -h $CHRENV/dev/shm ]; then
  install -v -d -m 1777 $CHRENV$(realpath /dev/shm)
else
  mounttype dev/shm tmpfs tmpfs -o nosuid,nodev
fi 
