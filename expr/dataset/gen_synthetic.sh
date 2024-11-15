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

FAIL=0

for dist in uniform gaussian; do
  for n in 10000000 20000000 30000000 40000000 50000000; do
    # generate polys about the center of USA
    dataset_name="${dist}_n_${n}.wkt"
    out_wkt="${DATASET_ROOT}/synthetic/$dataset_name"
    if [[ ! -f "$out_wkt" ]]; then
      ./generator.py distribution=$dist \
        cardinality=$n \
        dimensions=2 \
        seed=1 \
        geometry=box \
        polysize=0.01 \
        maxseg=3 \
        format=wkt \
        affinematrix=1,0,0,0,1,0 \
        maxsize=0.01,0.01 \
        affinematrix=1,0,0,0,1,0 >"$out_wkt" &
    fi
  done
done

for job in $(jobs -p); do
  echo "Job finished, PID $job"
  wait $job || let "FAIL+=1"
done

if [[ "$FAIL" -ne 0 ]]; then
  echo "FAIL! ($FAIL)"
fi

for dist in uniform gaussian; do
  for n in 10000000 20000000 30000000 40000000 50000000; do
    dataset_name="${dist}_n_${n}.wkt"
    in_wkt="${DATASET_ROOT}/synthetic/$dataset_name"

    for query_type in "point-contains" "range-contains" "range-intersects"; do
      output_dir="${DATASET_ROOT}/synthetic/${query_type}_queries_${SYNTHETIC_QUERY_SIZE}"
      output="${output_dir}/${dataset_name}"

      if [[ ! -f "$output" ]]; then
        mkdir -p "$output_dir"
        echo "Generating $output"
        "$BENCHMARK_ROOT"/gen -input "$in_wkt" \
          -output "$output" \
          -serialize "$SERIALIZE_ROOT" \
          -num_queries $SYNTHETIC_QUERY_SIZE \
          -query_type "$query_type" \
          -selectivity $SYNTHETIC_QUERY_SELECTIVITY &
      fi
    done
  done
done

for job in $(jobs -p); do
  echo "Job finished, PID $job"
  wait $job || let "FAIL+=1"
done

if [[ "$FAIL" -ne 0 ]]; then
  echo "FAIL! ($FAIL)"
fi
