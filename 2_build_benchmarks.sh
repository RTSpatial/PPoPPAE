#!/usr/bin/env bash
set -e

source ./common.sh

pushd "$AE_HOME"

if [[ ! -f "$AE_HOME/.benchmark" ]]; then
  rm -rf SpatialQueryBenchmark
  git clone https://github.com/RTSpatial/SpatialQueryBenchmark.git
  pushd SpatialQueryBenchmark
  mkdir -p build
  pushd build
  cmake .. -DCMAKE_PREFIX_PATH="$AE_DEPS_DIR" -DUSE_GPU=$AE_BUILD_GPU -DCMAKE_BUILD_TYPE=Release
  make query pip -j
  popd # build
  popd # SpatialQueryBenchmark
  touch "$AE_HOME/.benchmark"
fi

if [[ ! -f "$AE_HOME/.rayjoin" ]]; then
  rm -rf RayJoin
  git clone https://github.com/pwrliang/RayJoin.git -b load_wkt
  pushd RayJoin
  mkdir build
  pushd build
  cmake .. -DCMAKE_PREFIX_PATH="$AE_DEPS_DIR" -DCMAKE_BUILD_TYPE=Release
  make query_exec
  popd # build
  popd # RayJoin
  touch "$AE_HOME/.rayjoin"
fi

popd # AE_HOME
