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

function run_pip() {
  query_type="pip"
  index_type="$1"
  for wkt_file in "${DATASET_WKT_FILES_PIP[@]}"; do
    query_dir="${QUERY_ROOT}/point-contains_queries_${CONTAINS_QUERY_SIZE}"
    query="${query_dir}/${wkt_file}"
    log="${log_dir}/${query_type}_queries_${CONTAINS_QUERY_SIZE}/${index_type}/${wkt_file}.log"

    if [[ ! -f "${log}" ]]; then
      echo "${log}" | xargs dirname | xargs mkdir -p

      echo "Running query $query"
      if [[ $index_type == "cuspatial" ]]; then
        cmd="conda run -n ppopp-ae-rapids --live-stream python3 ${script_dir}/cuspatial_pip.py ${DATASET_ROOT}/polygons/${wkt_file} $query"
      else
        cmd="$BENCHMARK_ROOT/pip -geom ${DATASET_ROOT}/polygons/${wkt_file} \
        -query $query \
        -serialize $SERIALIZE_ROOT \
        -query_type $query_type \
        -index_type $index_type \
        -load_factor 0.001"
      fi

      echo "$cmd" >"${log}.tmp"
      eval "$cmd" 2>&1 | tee -a "${log}.tmp"

      if grep -q "Query Time" "${log}.tmp"; then
        mv "${log}.tmp" "${log}"
      fi
    fi
  done
}

function run_pip_rayjoin() {
  query_type="pip"
  index_type="rayjoin"

  for ((i = 0; i < "${#DATASET_WKT_FILES_PIP[@]}"; i++)); do
    wkt_file="${DATASET_WKT_FILES_PIP[i]}"
    cdb_file="${DATASET_CDB_FILES[i]}"
    query_dir="${QUERY_ROOT}/point-contains_queries_${CONTAINS_QUERY_SIZE}"
    query="${query_dir}/${wkt_file}"
    log="${log_dir}/${query_type}_queries_${CONTAINS_QUERY_SIZE}/${index_type}/${wkt_file}.log"

    if [[ ! -f "${log}" ]]; then
      echo "${log}" | xargs dirname | xargs mkdir -p

      echo "Running query $query"
      cmd="$RAYJOIN_ROOT/bin/query_exec -poly1 ${DATASET_ROOT}/polygons/${cdb_file} \
          -poly2 $query \
          -serialize $SERIALIZE_ROOT \
          -query pip \
          -mode rt \
          -check false"

      echo "$cmd" >"${log}.tmp"
      eval "$cmd" 2>&1 | tee -a "${log}.tmp"

      if grep -q "Timing results" "${log}.tmp"; then
        mv "${log}.tmp" "${log}"
      fi
    fi
  done
}

run_pip "rtspatial"
run_pip "cuspatial"
run_pip_rayjoin
