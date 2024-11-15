#!/usr/bin/env bash

get_script_dir() {
  local source="${BASH_SOURCE[0]}"
  while [ -h "$source" ]; do
    local dir
    dir=$(dirname "$source")
    source=$(readlink "$source")
    [[ $source != /* ]] && source="$dir/$source"
  done
  echo "$(cd -P "$(dirname "$source")" >/dev/null 2>&1 && pwd)"
}

AE_HOME="$(get_script_dir)"
AE_DEPS_DIR="$AE_HOME/deps"
AE_TMP_DIR="$AE_HOME/tmp"
AE_DATASETS_DIR="$AE_HOME/datasets"
AE_FIGURES_DIR="$AE_HOME/figures"
# If you build the benchmark on a machine without a GPU, set "USE_GPU=OFF"
AE_BUILD_GPU=ON
# Turn this ON/OFF depending whether you want to run CPU/GPU-based benchmarks
AE_RUN_GPU=ON
AE_RUN_CPU=ON

if [[ ! -d "$AE_TMP_DIR" ]]; then
  mkdir -p "$AE_TMP_DIR"
fi

