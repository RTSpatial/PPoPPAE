# PPoPPAE

## 1. Getting Started Guide
### 1.1 Hardware
To run the experiments, you need a machine equipped with an NVIDIA RTX Series GPU, ideally an RTX 3090 (as used in the paper). 
The GPU should have at least 24 GB of VRAM to run all experiments successfully. 
Non-RTX GPUs, such as the A100 or H100, should not be used to reproduce the results, as they lack RT cores. 
Additionally, the machine should have high-performance CPUs for evaluating CPU-based baselines and sufficient RAM to load the datasets (64 GB should be adequate).

Note that we do not explicitly specify which GPU to use in the code, so the first available GPU will be used in the experiments.
If your RTX GPU is not the first one, you should make it accessible to the benchmark program by setting `export CUDA_VISIBLE_DEVICES=x`, where x is the index of your RTX GPU.

### 1.2 Software
The user should make sure the following programs are available.
- bash
- git
- wget
- unzip
- tar
- md5sum
- gcc ([>=7.5](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html))
- Conda ([>=22.11](https://docs.rapids.ai/install/#system-req))
- CMake (>=3.27)
- CUDA (>=12)
- NVIDIA Driver (>=535)

The artifact is expected to run under a **Linux machine only**. You may use any Linux distribution you like.
Here's the environment I'm using.
- Ubuntu 20.04
- gcc 9.4.0
- CUDA 12.3
- NVIDIA Driver 550.127.05
- CMake 3.27.7
- Conda 23.9.0

### 1.3 How to run the experiments

If the above software requirements are met, simply navigate to the root of this repository 
and execute `./runme.sh`. This script will build and install dependencies, download datasets,
build and run baselines and finally, draw the figures in the paper. Once the script completes, Figures 7–13 will be generated and
can be found in `figures` folder within the root directory of this repository.

Since this paper evaluates both CPU and GPU based spatial libraries and your machine with a GPU may not
have a powerful CPU, so you want to run the CPU-based baselines on a different machine.
You can control whether to evaluate CPU/GPU-based baselines by setting variables
`AE_RUN_CPU` and `AE_RUN_GPU` in [common.sh](common.sh). Additionally, you may also set `AE_BUILD_GPU` to `OFF`
if your machine does not have installed CUDA.

If you run the CPU and GPU baselines on different machines, you should manually merge the
execution logs into the folder `expr/query/logs` and run [5_draw_figures.sh](5_draw_figures.sh)
to generate figures.

### 1.4 Variation of performance numbers 

If you are using a different GPU from us, you may see the difference in speedups than we reported numbers. 
In addition, the execution times of a small part of experiments are very short
(less than 1 millisecond or just a few milliseconds).  As a result, the reproduced results 
may vary significantly due to the precision of time measurements
and other incidental factors. This is particularly true for experiments involving the smallest dataset `USCounty`.



## 2. Step-by-Step Instructions
### 2.1 Explains of the scripts

By executing `runme.sh`, all the figures in the paper will be automatically generated. However, you may also want to know
what happens in this process. `runme.sh` 

The `runme.sh` script will sequentially execute `0_check_env.sh` through `5_draw_figures.sh`.


- `common.sh` Find the absolute path of this repo (`AE_HOME`) and define several working directories, such as dependencies (`AE_DEPS_DIR`), datasets (`AE_DATASETS_DIR`), temp dir (`AE_TMP_DIR`), and controls whether to build/run GPU/CPU-based benchmarks
- `0_check_env.sh` Check whether necessary commands are available
- `1_install_deps.sh` Build and install dependencies used by the benchmarks, such as gflags, glog, geos, boost, cgal, etc. These libraries will be installed to `$AE_HOME/deps`
- `2_build_benchmarks.sh` build the spatial query benchmarks evaluated in this paper. The benchmarks is a C++ program that calls various spatial libraries and measures the running time of spatial queries
- `3_download_datasets.sh` download the datasets from OneDrive and unzip it
- `4_run_experiments.sh` run experiments and generate logs only
- `5_draw_figures.sh` draw figures from the logs and copy the PDFs into `figures` folder


The performance numbers of RTSpatial and the baselines are mainly produced by `SpatialQueryBenchmark` in which
every spatial library will be evaluated and measured the running time. The summary of artifacts is listed in Table 1.
The evaluation of cuSpatial is not included in `SpatialQueryBenchmark` but is implemented in the separated python source files 
under `expr/query` named [cuspatial_point_contains.py](expr/query/cuspatial_point_contains.py) and [cuspatial_pip.py](expr/query/cuspatial_pip.py). 


### 2.2 Spatial Query Options
You may also want to run a query manually instead of using the scripts provided by us. Here are the explains of the usage

Binary Path: `SpatialQueryBenchmark/build/query`

Command Options:

| Option       | Notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
|--------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| -geom        | a Well-Known-Type (WKT) file containing polygons                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| -query       | a WKT file containing polygons or points                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| -serialize   | a writable directory to keep serialized dataset for fast loading (optional)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| -query_type  | "point-contains" (Point query) or "range-contains" (Range query with contains predicate) or "range-intersects" (Range query with intersect predicate)                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| -index_type  | can be "rtree", "glin", "cgal", "pargeo", "lbvh", and "rtspatial"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| -load_factor | This value only takes effective for GPU-based libraries. It determines how much memory will be preallocated to store query results. For example, 0.01 means # of geometries * # of queries * 0.01 entries will be allocated to store the query results. If this value is too small, a internal queue to store query results will be overrun and an "illegal memory accesses" error will show up. It this value is too large, the excessive memory space will be allocated, leading to out of memory error. Therefore, I suggest that this value should be slightly higher than selectivity of your query. |