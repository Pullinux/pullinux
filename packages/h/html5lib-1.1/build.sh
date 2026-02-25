patch -Np1 -i ../html5lib-1.1-python_3.14_buildfix-1.patch

sed -i 's/from pkg_resources import/from packaging.version import parse as/' setup.py 
sed -i 's/import pkg_resources/pkg_resources = None/' setup.py

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD
