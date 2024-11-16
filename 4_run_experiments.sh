#!/usr/bin/env bash
set -e

source ./common.sh

pushd "$AE_HOME"

if [[ ! -f "$AE_HOME/.datasets" ]]; then
  echo "datasets is not available"
  exit 1
fi

export DATASET_ROOT="$AE_DATASETS_DIR"
export SERIALIZE_ROOT="$AE_TMP_DIR/ser"
export BENCHMARK_ROOT="$AE_HOME/SpatialQueryBenchmark/build"
export RAYJOIN_ROOT="$AE_HOME/RayJoin/build"

pushd expr
pushd query

options=""
if [[ $AE_RUN_GPU == "ON" ]]; then
  options="--gpu"
fi
if [[ $AE_RUN_CPU == "ON" ]]; then
  options="$options --cpu"
fi

# Collect data for Fig 7-10
./query.sh ${options}

# Fig 11
./scalability.sh

# Fig 12
./update.sh

# Fig 13
if [[ $AE_RUN_GPU == "ON" ]]; then
  ./pip.sh
fi
popd # query
popd # expr

popd # AE_HOME
