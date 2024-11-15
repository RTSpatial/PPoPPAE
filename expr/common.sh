#!/usr/bin/env bash

# export DATASET_ROOT="/local/storage/liang/rtspatial/datasets"
# export SERIALIZE_ROOT="/local/storage/liang/rtspatial/ser"
export QUERY_ROOT="${DATASET_ROOT}/queries"
# export BENCHMARK_ROOT="/local/storage/liang/.clion/SpatialQueryBenchmark/cmake-build-release-dl190"
# export RAYJOIN_ROOT="/local/storage/liang/.clion/RayJoin/cmake-build-release-dl190"
export DATASET_WKT_FILES=("dtl_cnty.wkt"
  "USACensusBlockGroupBoundaries.wkt"
  "USADetailedWaterBodies.wkt"
  "parks_Europe.wkt"
  "lakes.bz2.wkt"
  "parks.bz2.wkt")
# PIP queries
export DATASET_WKT_FILES_PIP=("dtl_cnty.wkt"
  "USACensusBlockGroupBoundaries.wkt"
  "USADetailedWaterBodies.wkt"
  "parks_Europe.wkt")
export DATASET_CDB_FILES=("dtl_cnty.cdb"
  "USACensusBlockGroupBoundaries.cdb"
  "USADetailedWaterBodies.cdb"
  "parks_Europe.cdb")
export DATASET_VARY_SIZE="parks.bz2.wkt"
export CONTAINS_QUERY_SIZE=100000
export INTERSECTS_QUERY_SIZE=10000
export RAY_DUP_INTERSECTS_QUERY_SIZE=50000
export QUERY_VARY_SIZES_CONTAINS=(50000 100000 200000 400000 800000)
export QUERY_VARY_SIZES_INTERSECTS=(10000 20000 30000 40000 50000)
export BATCH_SIZES=(1000 10000 100000 1000000)
export RANGE_QUERY_INTERSECTS_QUALIFIED_SIZES=(1 10 100)
export RANGE_QUERY_INTERSECTS_SELECTIVITIES=("0.0001" "0.001" "0.01")
export RANGE_QUERY_INTERSECTS_LOAD_FACTORS=("0.002" "0.002" "0.015")
export SYNTHETIC_DATA_SIZES=(10000000 20000000 30000000 40000000 50000000)
export SYNTHETIC_QUERY_SELECTIVITY="0.001"
export SYNTHETIC_QUERY_SIZE=10000
export UPDATE_RATIOS=(0.0002 0.002 0.02 0.2)
