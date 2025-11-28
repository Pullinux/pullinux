sed 's/\[\[__nodiscard__]]//' -i lib/config.hin

sed 's/test-stdalign\$(EXEEXT) //' -i tests/Makefile.in
./configure --prefix=/usr
make
make DESTDIR=$PCKDIR install
