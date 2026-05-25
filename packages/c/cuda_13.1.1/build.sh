wget https://developer.download.nvidia.com/compute/cuda/13.1.1/local_installers/cuda_13.1.1_590.48.01_linux.run

mkdir -pv $PCKDIR/opt/cuda-13.1.1 &&
ln -sfv cuda-13.1.1 $PCKDIR/opt/cuda

sh cuda_13.1.1_590.48.01_linux.run     \
  --target cuda_13.1.1_590.48.01_linux \
  --noexec

pushd cuda_13.1.1_590.48.01_linux/builds
  rm -rf cuda_nsight cuda_sanitizer_api nsight_{compute,systems}
  rm -rvf bin integration NVIDIA*.run
  cp version.json $PCKDIR/opt/cuda-13.1.1
  cp EULA.txt     $PCKDIR/opt/cuda-13.1.1
  rm version.json EULA.txt
  mkdir -p $PCKDIR/opt/cuda-13.1.1/bin

  for lib in *; do
    cp -vR $lib/* $PCKDIR/opt/cuda-13.1.1
    rm -rf $lib
  done

  ln -svf lib64 $PCKDIR/opt/cuda-13.1.1/lib

  for mf in $(find $PCKDIR/opt/cuda-13.1.1 -name Makefile); do
    sed -i "s|/usr/local/cuda|/opt/cuda-13.1.1|g" "$mf"
  done
popd

rm -rf cuda_13.1.1_590.48.01_linux

sed -e "/.*unsupported GNU version.*/d" \
    -e "/.*unsupported clang version.*/d" \
    -i $PCKDIR/opt/cuda-13.1.1/targets/x86_64-linux/include/crt/host_config.h
