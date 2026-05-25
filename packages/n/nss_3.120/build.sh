#!/bin/bash

patch -Np1 -i ../nss-standalone-1.patch 

cd nss 

make BUILD_OPT=1                        \
     NSPR_INCLUDE_DIR=/usr/include/nspr \
     USE_SYSTEM_ZLIB=1                  \
     ZLIB_LIBS=-lz                      \
     NSS_ENABLE_WERROR=0                \
     USE_64=1                           \
     NSS_USE_SYSTEM_SQLITE=1

cd ../dist 

mkdir -p $PCKDIR/usr/lib/pkgconfig/
mkdir -p $PCKDIR/usr/bin/

install -vDm755 Linux*/lib/*.so              -t $PCKDIR/usr/lib/              
install -vDm644 Linux*/lib/{*.chk,libcrmf.a} -t $PCKDIR/usr/lib/              

install -vdm755                                 $PCKDIR/usr/include/nss       
cp -v -RL {public,private}/nss/*                $PCKDIR/usr/include/nss       

install -vDm755 Linux*/bin/{certutil,nss-config,pk12util} -t $PCKDIR/usr/bin/ 

install -vDm644 Linux*/lib/pkgconfig/nss.pc -t $PCKDIR/usr/lib/pkgconfig/



#32 bit

mkdir -p $PCKDIR/usr/lib32/pkgconfig/

cd ../nss                                         
find -name "Linux*.OBJ" -type d -exec rm -rf {} + 
rm -rf ../dist                                    

CC="gcc -m32" CXX="g++ -m32"            \
make BUILD_OPT=1                        \
     NSPR_INCLUDE_DIR=/usr/include/nspr \
     USE_SYSTEM_ZLIB=1                  \
     ZLIB_LIBS=-lz                      \
     NSS_ENABLE_WERROR=0                \
     NSS_USE_SYSTEM_SQLITE=1

cd ../dist 

install -vDm755 Linux*/lib/*.so              -t $PCKDIR/usr/lib32/           
install -vDm644 Linux*/lib/{*.chk,libcrmf.a} -t $PCKDIR/usr/lib32/           
sed -i 's/lib/lib32/g' Linux*/lib/pkgconfig/nss.pc                    
install -vDm644 Linux*/lib/pkgconfig/nss.pc  -t $PCKDIR/usr/lib32/pkgconfig/

