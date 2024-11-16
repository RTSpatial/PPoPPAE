#!/usr/bin/env bash
set -e

source ./common.sh

function download_unzip() {
  link=$1
  name="$2"
  checksum=$3
  filename="$name.tar.gz"
  if [[ ! -f ".$name" ]]; then
    if [[ ! -f "$filename" ]]; then
      conda run -n ppopp-ae-python --live-stream python3 "$AE_HOME"/download_dataset.py "$link" \
        "$filename"
    fi
    download_checksum=$(md5sum "$filename" | awk '{ print $1 }')
    if [[ $download_checksum == "$checksum" ]]; then
      rm -rf "$name" # remove dataset folder
      tar zxvf "$filename"
    else
      echo "checksum of $filename is incorrect, $download_checksum vs $checksum"
      exit 1
    fi
    touch ".$name"
  else
    echo "$name is downloaded, skip"
  fi

}

pushd "$AE_HOME"
mkdir -p "$AE_DATASETS_DIR"

if [[ ! -f "$AE_HOME/.datasets" ]]; then
  pushd datasets
  download_unzip "https://buckeyemailosu-my.sharepoint.com/:u:/g/personal/geng_161_buckeyemail_osu_edu/EXfY0lgd3TxEm7PdAVUyeBUBnkVS73yPuUQmD_SNZTQwPQ?e=zfyDCy" \
    "polygons" \
    "d5c2a8053fd0b7359a5b83391f7d0b82"

  download_unzip "https://buckeyemailosu-my.sharepoint.com/:u:/g/personal/geng_161_buckeyemail_osu_edu/ET0oD72sVAVChzAygsEMf6cBp9yLI96p1Q7wK50OJNU4OQ?e=ygp9u1" \
    "queries" \
    "64b560c3d067262b7ef7d7422c64225a"

  download_unzip "https://buckeyemailosu-my.sharepoint.com/:u:/g/personal/geng_161_buckeyemail_osu_edu/ES_1jKSdIKFCvnoRHy2Nt8gB634J_68E77oXanWpy6xVAg?e=xfupnL" \
    "synthetic" \
    "ebe7dcf4001132d297a8022c110cedeb"

  touch "$AE_HOME/.datasets"
  popd # datasets
else
  echo "Datasets is prepared, skip"
fi

popd # AE_HOME
