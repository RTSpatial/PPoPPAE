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

function gen_point_query_contains() {
  query_type="point-contains"
  for wkt_file in "${DATASET_WKT_FILES[@]}"; do
    output_dir="${QUERY_ROOT}/${query_type}_queries_${CONTAINS_QUERY_SIZE}"
    output="${output_dir}/${wkt_file}"

    if [[ ! -f "$output" ]]; then
      mkdir -p "$output_dir"
      echo "Generating $output"
      "$BENCHMARK_ROOT"/gen -input "${DATASET_ROOT}/polygons/${wkt_file}" \
        -serialize "$SERIALIZE_ROOT" \
        -output "$output" \
        -num_queries $CONTAINS_QUERY_SIZE \
        -query_type "$query_type"
    fi
  done
}

function gen_point_query_contains_vary_size() {
  query_type="point-contains"
  wkt_file="$DATASET_VARY_SIZE"
  for query_size in "${QUERY_VARY_SIZES_CONTAINS[@]}"; do
    output_dir="${QUERY_ROOT}/${query_type}_queries_${query_size}"
    output="${output_dir}/${wkt_file}"

    if [[ ! -f "$output" ]]; then
      mkdir -p "$output_dir"
      echo "Generating $output, size $query_size"
      "$BENCHMARK_ROOT"/gen -input "${DATASET_ROOT}/polygons/${wkt_file}" \
        -serialize "$SERIALIZE_ROOT" \
        -output "$output" \
        -num_queries $query_size \
        -query_type "$query_type"
    fi
  done
}

function gen_range_query_contains() {
  query_type="range-contains"
  for wkt_file in "${DATASET_WKT_FILES[@]}"; do
    output_dir="${QUERY_ROOT}/${query_type}_queries_${CONTAINS_QUERY_SIZE}"
    output="${output_dir}/${wkt_file}"

    if [[ ! -f "$output" ]]; then
      mkdir -p "$output_dir"
      echo "Generating $output"
      "$BENCHMARK_ROOT"/gen -input "${DATASET_ROOT}/polygons/${wkt_file}" \
        -serialize "$SERIALIZE_ROOT" \
        -output "$output" \
        -num_queries $CONTAINS_QUERY_SIZE \
        -query_type "$query_type"
    fi
  done
}

function gen_range_query_contains_vary_size() {
  query_type="range-contains"
  wkt_file="$DATASET_VARY_SIZE"
  for query_size in "${QUERY_VARY_SIZES_CONTAINS[@]}"; do
    output_dir="${QUERY_ROOT}/${query_type}_queries_${query_size}"
    output="${output_dir}/${wkt_file}"

    if [[ ! -f "$output" ]]; then
      mkdir -p "$output_dir"
      echo "Generating $output"
      "$BENCHMARK_ROOT"/gen -input "${DATASET_ROOT}/polygons/${wkt_file}" \
        -serialize "$SERIALIZE_ROOT" \
        -output "$output" \
        -num_queries $query_size \
        -query_type "$query_type"
    fi
  done
}

function gen_range_query_intersects() {
  query_type="range-intersects"
  query_size=$1
  for wkt_file in "${DATASET_WKT_FILES[@]}"; do
    for selectivity in "${RANGE_QUERY_INTERSECTS_SELECTIVITIES[@]}"; do
      output_dir="${QUERY_ROOT}/${query_type}_select_${selectivity}_queries_${query_size}"
      output="${output_dir}/${wkt_file}"

      if [[ ! -f "$output" ]]; then
        mkdir -p "$output_dir"
        echo "Generating $output"
        "$BENCHMARK_ROOT"/gen -input "${DATASET_ROOT}/polygons/${wkt_file}" \
          -serialize "$SERIALIZE_ROOT" \
          -output "$output" \
          -selectivity $selectivity \
          -num_queries $query_size \
          -query_type "$query_type"
      fi
    done
  done
}

function gen_range_query_intersects_vary_size() {
  query_type="range-intersects"
  selectivity=$1
  wkt_file="$DATASET_VARY_SIZE"
  for query_size in "${QUERY_VARY_SIZES_INTERSECTS[@]}"; do
    output_dir="${QUERY_ROOT}/${query_type}_select_${selectivity}_queries_${query_size}"
    output="${output_dir}/${wkt_file}"

    if [[ ! -f "$output" ]]; then
      mkdir -p "$output_dir"
      echo "Generating $output"
      "$BENCHMARK_ROOT"/gen -input "${DATASET_ROOT}/polygons/${wkt_file}" \
        -serialize "$SERIALIZE_ROOT" \
        -output "$output" \
        -selectivity $selectivity \
        -num_queries $query_size \
        -query_type "$query_type"
    fi
  done
}

gen_point_query_contains
gen_point_query_contains_vary_size

gen_range_query_contains
gen_range_query_contains_vary_size

gen_range_query_intersects $INTERSECTS_QUERY_SIZE
#gen_range_query_intersects $RAY_DUP_INTERSECTS_QUERY_SIZE
gen_range_query_intersects_vary_size "0.001"
