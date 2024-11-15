#!/usr/bin/env bash

# Function to resolve the script path
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
script_dir=$(get_script_dir)

source "${script_dir}/../common.sh"

log_dir="${script_dir}/logs"

function run_point_query_contains() {
  query_type="point-contains"

  for dist in "uniform" "gaussian"; do
    for size in "${SYNTHETIC_DATA_SIZES[@]}"; do
      wkt_file="${dist}_n_${size}.wkt"
      query_dir="${DATASET_ROOT}/synthetic/${query_type}_queries_${SYNTHETIC_QUERY_SIZE}"
      query="${query_dir}/${wkt_file}"
      log="${log_dir}/scalability_${size}_${query_type}/${wkt_file}.log"

      if [[ ! -f "${log}" ]]; then
        echo "${log}" | xargs dirname | xargs mkdir -p

        echo "Running query $query"
        cmd="$BENCHMARK_ROOT/query -geom ${DATASET_ROOT}/synthetic/${wkt_file} \
          -query $query \
          -serialize $SERIALIZE_ROOT \
          -query_type $query_type \
          -index_type rtspatial \
          -load_factor 0.0001"

        echo "$cmd" >"${log}.tmp"
        eval "$cmd" 2>&1 | tee -a "${log}.tmp"

        if grep -q "Query Time" "${log}.tmp"; then
          mv "${log}.tmp" "${log}"
        fi
      fi
    done
  done
}

function run_range_query_contains() {
  query_type="range-contains"

  for dist in "uniform" "gaussian"; do
    for size in "${SYNTHETIC_DATA_SIZES[@]}"; do
      wkt_file="${dist}_n_${size}.wkt"
      query_dir="${DATASET_ROOT}/synthetic/${query_type}_queries_${SYNTHETIC_QUERY_SIZE}"
      query="${query_dir}/${wkt_file}"
      log="${log_dir}/scalability_${size}_${query_type}/${wkt_file}.log"

      if [[ ! -f "${log}" ]]; then
        echo "${log}" | xargs dirname | xargs mkdir -p

        echo "Running query $query"
        cmd="$BENCHMARK_ROOT/query -geom ${DATASET_ROOT}/synthetic/${wkt_file} \
          -query $query \
          -serialize $SERIALIZE_ROOT \
          -query_type range-contains \
          -index_type rtspatial \
          -load_factor 0.0001"

        echo "$cmd" >"${log}.tmp"
        eval "$cmd" 2>&1 | tee -a "${log}.tmp"

        if grep -q "Query Time" "${log}.tmp"; then
          mv "${log}.tmp" "${log}"
        fi
      fi
    done
  done
}

function run_range_query_intersects() {
  query_type="range-intersects"

  for dist in "uniform" "gaussian"; do
    for size in "${SYNTHETIC_DATA_SIZES[@]}"; do
      wkt_file="${dist}_n_${size}.wkt"
      query_dir="${DATASET_ROOT}/synthetic/${query_type}_queries_${SYNTHETIC_QUERY_SIZE}"
      query="${query_dir}/${wkt_file}"
      log="${log_dir}/scalability_${size}_${query_type}/${wkt_file}.log"

      if [[ ! -f "${log}" ]]; then
        echo "${log}" | xargs dirname | xargs mkdir -p

        echo "Running query $query"
        cmd="$BENCHMARK_ROOT/query -geom ${DATASET_ROOT}/synthetic/${wkt_file} \
          -query $query \
          -serialize $SERIALIZE_ROOT \
          -query_type range-intersects \
          -index_type rtspatial \
          -load_factor 0.003"

        echo "$cmd" >"${log}.tmp"
        eval "$cmd" 2>&1 | tee -a "${log}.tmp"

        if grep -q "Query Time" "${log}.tmp"; then
          mv "${log}.tmp" "${log}"
        fi
      fi
    done
  done
}

run_point_query_contains
run_range_query_contains
run_range_query_intersects
