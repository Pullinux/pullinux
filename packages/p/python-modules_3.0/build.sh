wget https://files.pythonhosted.org/packages/source/t/trove_classifiers/trove_classifiers-2026.1.14.14.tar.gz

tar -xf trove_classifiers-2026.1.14.14.tar.gz

cd trove_classifiers-2026.1.14.14

sed -i '/calver/s/^/#/;$iversion="2026.1.14.14"' setup.py

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD
pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user trove-classifiers

cd ..

wget https://files.pythonhosted.org/packages/source/s/setuptools_scm/setuptools_scm-9.2.2.tar.gz
tar -xf setuptools_scm-9.2.2.tar.gz
cd setuptools_scm-9.2.2

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD

pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user setuptools_scm


cd ..

wget https://files.pythonhosted.org/packages/source/p/pluggy/pluggy-1.6.0.tar.gz
tar -xf pluggy-1.6.0.tar.gz
cd pluggy-1.6.0

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD
pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user pluggy

cd ..
wget https://files.pythonhosted.org/packages/source/p/pathspec/pathspec-1.0.4.tar.gz
tar -xf pathspec-1.0.4.tar.gz

cd pathspec-1.0.4

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD

pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user pathspec

cd ..

wget https://files.pythonhosted.org/packages/source/e/editables/editables-0.5.tar.gz
tar -xf editables-0.5.tar.gz

cd editables-0.5

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD

pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user editables

cd ..

wget https://files.pythonhosted.org/packages/source/h/hatchling/hatchling-1.28.0.tar.gz
tar -xf hatchling-1.28.0.tar.gz
cd hatchling-1.28.0

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD

pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user hatchling

cd ..

wget https://files.pythonhosted.org/packages/source/h/hatch-vcs/hatch_vcs-0.5.0.tar.gz
tar -xf hatch_vcs-0.5.0.tar.gz

cd hatch_vcs-0.5.0

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD

pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user hatch_vcs

cd ..

wget https://files.pythonhosted.org/packages/source/u/urllib3/urllib3-2.6.3.tar.gz
tar -xf urllib3-2.6.3.tar.gz
cd urllib3-2.6.3

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD

pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user urllib3

cd ..

wget https://files.pythonhosted.org/packages/source/i/idna/idna-3.11.tar.gz
tar -xf idna-3.11.tar.gz
cd idna-3.11

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD

pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user idna

cd ..

wget https://files.pythonhosted.org/packages/source/c/charset-normalizer/charset_normalizer-3.4.4.tar.gz
tar -xf charset_normalizer-3.4.4.tar.gz
cd charset_normalizer-3.4.4

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD

pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user charset-normalizer

cd ..

wget https://files.pythonhosted.org/packages/source/r/requests/requests-2.32.5.tar.gz
wget https://www.linuxfromscratch.org/patches/blfs/13.0/requests-use_system_certs-1.patch

tar -xf requests-2.32.5.tar.gz
cd requests-2.32.5
patch -Np1 -i ../requests-use_system_certs-1.patch

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD

pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user requests

cd ..

wget https://files.pythonhosted.org/packages/source/d/doxyqml/doxyqml-0.5.3.tar.gz

tar -xf doxyqml-0.5.3.tar.gz

cd doxyqml-0.5.3

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD

pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user doxyqml

cd ..

wget https://files.pythonhosted.org/packages/source/c/chardet/chardet-5.2.0.tar.gz

tar -xf chardet-5.2.0.tar.gz

cd chardet-5.2.0

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD

pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user chardet

cd ..

wget https://files.pythonhosted.org/packages/source/d/doxypypy/doxypypy-0.8.8.7.tar.gz
tar -xf doxypypy-0.8.8.7.tar.gz
cd doxypypy-0.8.8.7

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD

pip3 install --no-index --find-links $PCKDIR/.install/dist --no-user doxypypy
