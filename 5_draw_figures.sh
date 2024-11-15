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
mv fig*.pdf "$AE_FIGURES_DIR"
popd # $AE_HOME/expr/draw
popd # AE_HOME
