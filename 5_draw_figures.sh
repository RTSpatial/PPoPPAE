#!/usr/bin/env bash
set -e

source ./common.sh

pushd "$AE_HOME"

mkdir -p "$AE_FIGURES_DIR"
pushd "$AE_HOME/expr/draw"
LOGS_DIR="$AE_HOME/expr/query/logs"
conda run -n ppopp-ae-python --live-stream python3 draw_query.py "$LOGS_DIR"
conda run -n ppopp-ae-python --live-stream python3 draw_scalability.py "$LOGS_DIR"
conda run -n ppopp-ae-python --live-stream python3 draw_update.py "$LOGS_DIR"
conda run -n ppopp-ae-python --live-stream python3 draw_pip.py "$LOGS_DIR"
mv point_query.pdf "$AE_FIGURES_DIR/fig7.pdf"
mv range_contains_query.pdf "$AE_FIGURES_DIR/fig8.pdf"
mv range_intersects_query.pdf "$AE_FIGURES_DIR/fig9.pdf"
mv dup_rays.pdf "$AE_FIGURES_DIR/fig10.pdf"
mv scalability.pdf "$AE_FIGURES_DIR/fig11.pdf"
mv update_all.pdf "$AE_FIGURES_DIR/fig12.pdf"
mv pip_time.pdf "$AE_FIGURES_DIR/fig13.pdf"
popd # $AE_HOME/expr/draw
popd # AE_HOME
