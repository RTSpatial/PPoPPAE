# PPoPPAE

## 1. Getting Started Guide
### 1.1 Hardware
To run the experiments, you need a machine equipped with an NVIDIA RTX Series GPU, ideally an RTX 3090 (as used in the paper). 
The GPU should have at least 24 GB of VRAM to run all experiments successfully. 
Non-RTX GPUs, such as the A100 or H100, should not be used to reproduce the results, as they don't have RT cores. 
Additionally, the machine should have high-performance CPUs for evaluating CPU-based baselines and sufficient RAM to load the datasets (64 GB should be adequate).

Note that we do not explicitly specify which GPU to use in the code, so the first available GPU will be used in the experiments.
If your RTX GPU is not the first one, you should make it accessible to the benchmark program by setting `export CUDA_VISIBLE_DEVICES=x`, where x is the index of your RTX GPU.

### 1.2 Software
The user should make sure the following programs are available.
- bash
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

If you run the CPU and GPU baselines on different machines, [5_draw_figures.sh](5_draw_figures.sh) will fail because some
logs are missing. You should manually merge the execution logs into the folder `expr/query/logs`.
This can be done with `rsync -avz MACHINE_A:/path/to/PPoPPAE/expr/query/logs/* /path/to/PPoPPAE/expr/query/logs/`.
Then you can run [5_draw_figures.sh](5_draw_figures.sh) to generate figures.

### 1.4 Variation of performance numbers 

If you are using a different GPU than ours, you may observe differences in speedups compared to the numbers we reported. 
Additionally, the execution times for a small subset of experiments are very short (less than 1 millisecond or just a few milliseconds). 
As a result, the reproduced results may vary significantly due to the precision of time measurements and other incidental factors. 
This is especially true for experiments involving the smallest dataset, `USCounty`.


## 2. Step-by-Step Instructions
### 2.1 Explains of the scripts

By executing `runme.sh`, all the figures presented in the paper will be automatically generated.
However, you may also want to understand the steps involved in this process.

The `runme.sh` script sequentially executes the following scripts: `0_check_env.sh` through `5_draw_figures.sh`.

- **`common.sh`**: Defines the absolute path of the repository (`AE_HOME`) and several working directories, such as dependencies (`AE_DEPS_DIR`), datasets (`AE_DATASETS_DIR`), a temporary directory (`AE_TMP_DIR`), and controls whether GPU/CPU-based benchmarks are built and run.
- **`0_check_env.sh`**: Checks whether the required commands and tools are available in the environment.
- **`1_install_deps.sh`**: Builds and installs the dependencies required by the benchmarks, including libraries such as `gflags`, `glog`, `geos`, `boost`, and `cgal`. These dependencies are installed in `$AE_HOME/deps`.
- **`2_build_benchmarks.sh`**: Compiles the spatial query benchmarks evaluated in the paper. These benchmarks are C++ programs that call various spatial libraries and measure the running time of spatial queries.
- **`3_download_datasets.sh`**: Downloads the datasets from OneDrive and unzips them.
- **`4_run_experiments.sh`**: Runs the experiments and generates logs.
- **`5_draw_figures.sh`**: Generates figures from the logs and copies the resulting PDFs into the `figures` folder.

Note that the evaluation of cuSpatial is not included in `SpatialQueryBenchmark`. Instead, it is implemented in separate Python scripts located in the `expr/query` directory, specifically [cuspatial_point_contains.py](expr/query/cuspatial_point_contains.py) and [cuspatial_pip.py](expr/query/cuspatial_pip.py).

### 2.2 Spatial Query Options
You may also want to run a query manually instead of using the provided scripts. Below is an explanation of the usage:

### Binary Path:
`SpatialQueryBenchmark/build/query`

### Command Options:

| **Option**    | **Description**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
|---------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **-geom**     | Specifies a Well-Known Text (WKT) file containing polygons.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **-query**    | Specifies a WKT file containing queries in the form of polygons or points.                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| **-serialize**| Specifies a writable directory to store a serialized version of the dataset for faster loading (optional).                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| **-query_type**| Defines the type of query: `"point-contains"` (Point query), `"range-contains"` (Range query with a contains predicate), or `"range-intersects"` (Range query with an intersects predicate).                                                                                                                                                                                                                                                                                                                                                    |
| **-index_type**| Specifies the index type, which can be `"rtree"`, `"glin"`, `"cgal"`, `"pargeo"`, `"lbvh"`, or `"rtspatial"`.                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| **-load_factor**| Relevant only for GPU-based libraries. Determines how much memory is preallocated to store query results. For example, a value of `0.01` means `# of geometries * # of queries * 0.01` entries will be allocated. If this value is too small, the internal queue for storing query results may overrun, causing an "illegal memory access" error. If it is too large, excessive memory may be allocated, potentially leading to an out-of-memory error. It is recommended to set this value slightly higher than the selectivity of your query. | 

