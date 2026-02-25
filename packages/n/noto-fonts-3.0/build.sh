wget https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/03_NotoSerifCJK-TTF-VF.zip

unzip 03_NotoSerifCJK-TTF-VF.zip

cd Variable/TTF

install -v -d -m755 $PCKDIR/usr/share/fonts/noto 
install -v -m644 *.ttf $PCKDIR/usr/share/fonts/noto 



