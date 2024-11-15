# PPoPPAE

## 1. What do the users need to install for reproduce the results
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

## 2. How to run the experiments

If the above software requirements are met, simply navigate to the root of this repository 
and execute `./runme.sh`.
The `runme.sh` script will sequentially execute `0_check_env.sh` through `5_draw_figures.sh`.
Once the script completes, Figures 7–13 will be generated and 
can be found in `figures` folder within the root directory of this repository.

**Important Notes on Differences in Reproduced Results**
Please note that RTSpatial and other baseline methods 
may have very short execution times (less than 1 millisecond or just a few milliseconds) 
in certain experiments. 
As a result, the reproduced results may vary significantly due to the precision of time measurements 
and other incidental factors. This is particularly true for experiments involving the `USCounty` dataset.



## 3. What are the scripts under the root of this repo?

- `common.sh` Find the absolute path of this repo (`AE_HOME`) and define several working directories, such as dependencies (`AE_DEPS_DIR`), datasets (`AE_DATASETS_DIR`), temp dir (`AE_TMP_DIR`), and controls whether to build/run GPU/CPU-based benchmarks 
- `0_check_env.sh` Check whether necessary commands are available
- `1_install_deps.sh` Build and install dependencies used by the benchmarks, such as gflags, glog, geos, boost, cgal, etc. These libraries will be installed to `$AE_HOME/deps`
- `2_build_benchmarks.sh` build the spatial query benchmarks evaluated in this paper. The benchmarks is a C++ program that calls various spatial libraries and measures the running time of spatial queries
- `3_download_datasets.sh` download the datasets from OneDrive and unzip it
- `4_run_experiments.sh` run experiments and generate logs only
- `5_draw_figures.sh` draw figures from the logs and copy the PDFs into `figures` folder