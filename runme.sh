#!/usr/bin/env bash
set -e

./0_check_env.sh
./1_install_deps.sh
./2_build_benchmarks.sh
./3_download_datasets.sh
./4_run_experiments.sh
./5_draw_figures.sh