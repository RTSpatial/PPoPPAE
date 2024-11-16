#!/usr/bin/env bash
set -e

source ./common.sh

pushd "$AE_TMP_DIR"

if [[ ! -f "$AE_HOME/.gflags" ]]; then
  wget "https://github.com/gflags/gflags/archive/refs/tags/v2.2.2.zip" -O "$AE_TMP_DIR/gflags.zip"
  rm -rf gflags-2.2.2
  unzip "$AE_TMP_DIR/gflags.zip"
  pushd gflags-2.2.2
  mkdir -p build
  pushd build
  cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX="$AE_DEPS_DIR" -DCMAKE_BUILD_TYPE=Release ..
  make -j install
  popd # build
  popd # gflags-2.2.2
  touch "$AE_HOME/.gflags"
else
  echo "gflags is installed, skip"
fi

if [[ ! -f "$AE_HOME/.glog" ]]; then
  wget "https://github.com/google/glog/archive/refs/tags/v0.6.0.tar.gz" -O "$AE_TMP_DIR/glog.tar.gz"
  rm -rf glog-0.6.0
  tar zxf "$AE_TMP_DIR/glog.tar.gz"
  pushd glog-0.6.0
  mkdir -p build
  pushd build
  cmake -DBUILD_SHARED_LIBS=ON -DWITH_GTEST=OFF -DCMAKE_PREFIX_PATH="$AE_DEPS_DIR" -DCMAKE_INSTALL_PREFIX="$AE_DEPS_DIR" -DCMAKE_BUILD_TYPE=Release ..
  make -j install
  popd # build
  popd # glog-0.6.0
  touch "$AE_HOME/.glog"
else
  echo "glog is installed, skip"
fi

if [[ ! -f "$AE_HOME/.geos" ]]; then
  wget "https://github.com/libgeos/geos/releases/download/3.11.0/geos-3.11.0.tar.bz2" -O "$AE_TMP_DIR/geos.tar.bz2"
  rm -rf geos-3.11.0
  tar jxf geos.tar.bz2
  pushd geos-3.11.0
  mkdir -p build
  pushd build
  cmake -DCMAKE_INSTALL_PREFIX="$AE_DEPS_DIR" -DCMAKE_BUILD_TYPE=Release ..
  make -j install
  popd # build
  popd # geos-3.11.0
  touch "$AE_HOME/.geos"
else
  echo "geos is installed, skip"
fi

if [[ ! -f "$AE_HOME/.cgal" ]]; then
  wget "https://github.com/CGAL/cgal/releases/download/v5.6.1/CGAL-5.6.1.zip" -O "$AE_TMP_DIR/cgal.zip"
  rm -rf CGAL-5.6.1
  unzip cgal.zip
  pushd CGAL-5.6.1
  mkdir -p build
  pushd build
  cmake -DCMAKE_INSTALL_PREFIX="$AE_DEPS_DIR" -DCMAKE_BUILD_TYPE=Release ..
  make -j install
  popd # build
  popd # CGAL-5.6.1
  touch "$AE_HOME/.cgal"
else
  echo "cgal is installed, skip"
fi

if [[ ! -f "$AE_HOME/.boost" ]]; then
  wget "https://archives.boost.io/release/1.85.0/source/boost_1_85_0.tar.bz2" -O "$AE_TMP_DIR/boost.tar.bz2"
  rm -rf boost_1_85_0
  tar jxf boost.tar.bz2
  pushd boost_1_85_0
  ./bootstrap.sh --prefix="$AE_DEPS_DIR" --without-libraries=python
  ./b2 install
  popd # boost_1_85_0
  touch "$AE_HOME/.boost"
else
  echo "boost is installed, skip"
fi

if [[ ! -f "$AE_HOME/.optix" ]]; then
  "$AE_HOME"/NVIDIA-OptiX-SDK-8.0.0-linux64-x86_64.sh --prefix="$AE_DEPS_DIR" --exclude-subdir --skip-license
  touch "$AE_HOME/.optix"
else
  echo "OptiX is installed, skip"
fi

if [[ ! -f "$AE_HOME/.rtspatial" ]]; then
  pushd "$AE_HOME/RTSpatial"
  mkdir -p build
  pushd build
  cmake -DCMAKE_INSTALL_PREFIX="$AE_DEPS_DIR" -DCMAKE_BUILD_TYPE=Release ..
  make -j install
  popd # build
  popd # "$AE_HOME/RTSpatial"
  touch "$AE_HOME/.rtspatial"
else
  echo "RTSpatial is installed, skip"
fi

if [[ "$AE_BUILD_GPU" == "ON" ]]; then
  if [[ ! $(conda env list | grep ppopp-ae-rapids) ]]; then
    echo "Installing cuSpatial. This can take a long time."
    conda install -n base conda-libmamba-solver -y
    conda create --solver=libmamba -n ppopp-ae-rapids -c rapidsai -c conda-forge -c nvidia \
      cuspatial=24.08 cuproj=24.08 python=3.11 'cuda-version>=12.0,<=12.5' -y
  else
    echo "cuSpatial is installed, skip"
  fi
else
  echo "Skip to install GPU-related dependencies"
fi

if [[ ! $(conda env list | grep ppopp-ae-python) ]]; then
  echo "Create python environment"
  conda create -n ppopp-ae-python python=3.11 -y
  conda run -n ppopp-ae-python --live-stream pip install -r "$AE_HOME/requirements.txt"
fi

popd # "$AE_TMP_DIR"
