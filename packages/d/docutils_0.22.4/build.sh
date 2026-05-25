for f in /usr/bin/rst*.py; do
  rm -fv /usr/bin/$(basename $f .py)
done

pip3 wheel -w $PCKDIR/.install/dist --no-build-isolation --no-deps --no-cache-dir $PWD
