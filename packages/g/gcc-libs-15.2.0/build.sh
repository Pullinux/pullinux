cat > pckfiles << EOF
./usr/lib/libgcc_s.so.1
./usr/lib/libgcc_s.so
./usr/lib/libstdc++.so.6.0.34
./usr/lib/libstdc++.so.6
./usr/lib/libstdc++.so
./usr/lib/libgomp.so.1.0.0
./usr/lib/libgomp.so.1
./usr/lib/libgomp.so
./usr/lib/libatomic.so.1.2.0
./usr/lib/libatomic.so.1
./usr/lib/libatomic.so
EOF

mkdir ext 
cd ext
tar -xf /usr/share/pullinux/packages/bin/gcc-15.2.0-plx-3.0.txz

mkdir -p $PCKDIR/usr/lib/

ls -ls ./usr/lib/

for f in $(cat ../pckfiles)
do
    mv $f $PCKDIR/usr/lib/
done;

ls -ls $PCKDIR/usr/lib/


