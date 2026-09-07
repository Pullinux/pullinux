set -e

echo "Installing in ${LFS:?}"

. utils.sh
. dev-packages.sh


build_package "cmake" "https://cmake.org/files/v4.4/cmake-4.4.2.tar.gz"
build_package "llvm" "https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.8/llvm-project-22.1.8.src.tar.xz" "https://www.linuxfromscratch.org/glfs/view/13.1/download/llvm-project/llvm-project-22.1.8-upstream_fix-1.patch"
build_package "rust" "https://static.rust-lang.org/dist/rustc-1.97.1-src.tar.xz"
build_package "cbindgen" "https://github.com/mozilla/cbindgen/archive/v0.29.4/cbindgen-0.29.4.tar.gz"
build_package "rbindgen" "https://github.com/rust-lang/rust-bindgen/archive/refs/tags/v0.72.1/rust-bindgen-0.72.1.tar.gz"
build_package "mako" "https://files.pythonhosted.org/packages/source/M/Mako/mako-1.4.1.tar.gz"
build_package "cython" "https://github.com/cython/cython/releases/download/3.2.9/cython-3.2.9.tar.gz"
build_package "libyaml" "https://github.com/yaml/libyaml/releases/download/0.2.5/yaml-0.2.5.tar.gz"
build_package "pyyaml" "https://files.pythonhosted.org/packages/source/P/PyYAML/pyyaml-6.0.3.tar.gz"
build_package "docutils" "https://files.pythonhosted.org/packages/source/d/docutils/docutils-0.23.tar.gz"
build_package "psutil" "https://files.pythonhosted.org/packages/source/p/psutil/psutil-7.2.2.tar.gz"
build_package "pathspec" "https://files.pythonhosted.org/packages/source/p/pathspec/pathspec-1.1.1.tar.gz"
build_package "vcs_versioning" "https://files.pythonhosted.org/packages/source/v/vcs_versioning/vcs_versioning-2.2.4.tar.gz"
build_package "setuptools_scm" "https://files.pythonhosted.org/packages/source/s/setuptools_scm/setuptools_scm-10.1.2.tar.gz"
build_package "pluggy" "https://files.pythonhosted.org/packages/source/p/pluggy/pluggy-1.6.0.tar.gz"
build_package "poetry_core" "https://files.pythonhosted.org/packages/source/p/poetry_core/poetry_core-2.4.1.tar.gz"
build_package "tomlkit" "https://files.pythonhosted.org/packages/source/t/tomlkit/tomlkit-0.15.1.tar.gz"
build_package "trove_classifiers" "https://files.pythonhosted.org/packages/source/t/trove_classifiers/trove_classifiers-2026.6.1.19.tar.gz"
build_package "hatchling" "https://files.pythonhosted.org/packages/source/h/hatchling/hatchling-1.32.0.tar.gz"
build_package "hatch_vcs" "https://files.pythonhosted.org/packages/source/h/hatch-vcs/hatch_vcs-0.5.0.tar.gz"
build_package "urllib3" "https://files.pythonhosted.org/packages/source/u/urllib3/urllib3-2.7.0.tar.gz"
build_package "semantic_version" "https://files.pythonhosted.org/packages/source/s/semantic_version/semantic_version-2.10.0.tar.gz"
build_package "setuptools_rust" "https://files.pythonhosted.org/packages/source/s/setuptools_rust/setuptools_rust-1.12.1.tar.gz"
build_package "maturin" "https://github.com/PyO3/maturin/archive/v1.14.1/maturin-1.14.1.tar.gz"
build_package "uv_build" "https://files.pythonhosted.org/packages/source/u/uv_build/uv_build-0.11.24.tar.gz"
build_package "pygments" "https://files.pythonhosted.org/packages/source/P/Pygments/pygments-2.20.0.tar.gz"
build_package "six" "https://files.pythonhosted.org/packages/source/s/six/six-1.17.0.tar.gz"
build_package "" ""
build_package "" ""
build_package "" ""
build_package "" ""
