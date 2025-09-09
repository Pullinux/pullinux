mkdir __build && cd __build

meson setup                                            \
      --prefix=/usr                                    \
      --buildtype=release                              \
      -D documentation=false                           \
      -D kerberos=false                                \
      -D google_client_secret=5ntt6GbbkjnTVXx-MSxbmx5e \
      -D google_client_id=595013732528-llk8trb03f0ldpqq6nprjp1s79596646.apps.googleusercontent.com \
      .. 
      
ninja
DESTDIR=$PCKDIR ninja install
