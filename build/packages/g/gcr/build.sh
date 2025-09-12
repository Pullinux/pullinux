sed -i 's:"/desktop:"/org:' schema/*.xml 

mkdir build 
cd    build 

meson setup --prefix=/usr       \
            --buildtype=release \
            -D gtk_doc=false    \
            -D ssh_agent=false  \
            ..   

meson setup --prefix=/usr --buildtype=release ..
ninja
DESTDIR=$PCKDIR ninja install
