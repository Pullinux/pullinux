#!/bin/bash

(for i in Bundles/{Alone,Alone7z,Format7zF,SFXCon} UI/Console; do
    make -C CPP/7zip/$i -f ../../cmpl_gcc.mak || exit
done)

mkdir -p $PCKDIR/usr/lib/
mkdir -p $PCKDIR/usr/bin

install -vDm755 CPP/7zip/Bundles/Alone{/b/g/7za,7z/b/g/7zr} \
                CPP/7zip/Bundles/Format7zF/b/g/7z.so        \
                CPP/7zip/UI/Console/b/g/7z                  \
                -t $PCKDIR/usr/lib/7zip/                           &&

install -vm755 CPP/7zip/Bundles/SFXCon/b/g/7zCon \
               $PCKDIR/usr/lib/7zip/7zCon.sfx           &&

(for i in 7z 7za 7zr; do
    cat > $PCKDIR/usr/bin/$i << EOF || exit
#!/bin/sh
exec /usr/lib/7zip/$i "\$@"
EOF
    chmod 755 $PCKDIR/usr/bin/$i || exit
done) &&

mkdir -p $PCKDIR/usr/share/doc/

cp -rv DOC -T $PCKDIR/usr/share/doc/7zip-26.00

