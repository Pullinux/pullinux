
sed -i 's/constexpr/unifdef_&/g' unifdef.c

sed -i 's/ln -s/ln -sf/' Makefile

make

make prefix=/usr DESTDIR=$PCKDIR install

