#!/usr/bin/env bash
set -e

source ./common.sh

function download_unzip() {
  link=$1
  name="$2"
  checksum=$3
  filename="$name.tar.bz2"
  if [[ ! -f ".$name" ]]; then
    if [[ ! -f "$filename" ]]; then
      conda run -n ppopp-ae-python --live-stream python3 "$AE_HOME"/download_dataset.py "$link" \
        "$filename"
    fi
    download_checksum=$(md5sum "$filename" | awk '{ print $1 }')
    if [[ $download_checksum == "$checksum" ]]; then
      rm -rf "$name" # remove dataset folder
      tar jxvf "$filename"
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
  download_unzip "https://buckeyemailosu-my.sharepoint.com/:u:/g/personal/geng_161_buckeyemail_osu_edu/EThli6sqqExEnTR4sE-tPt0B6W6wrtLi4LO57bvUkQbv1A?e=k1d1L5" \
    "polygons" \
    "266d9febc270f0f8e0e78fc49c5eca64"

  download_unzip "https://buckeyemailosu-my.sharepoint.com/:u:/g/personal/geng_161_buckeyemail_osu_edu/ER3IFW1VVs9AkzWdrmd4egkBCKv4SPPhb8JuBRvTpbfOCA?e=8cs2XK" \
    "queries" \
    "8117bdc5bee83d2fa37a1558cc733643"

  download_unzip "https://buckeyemailosu-my.sharepoint.com/:u:/g/personal/geng_161_buckeyemail_osu_edu/EXEkg7cDJMZOrlbZo3oilFAB4m_BmxIVUCW9slplqxYfTA?e=lkpbxo" \
    "synthetic" \
    "da9bdb4eb53e2ee947738ecd333d4a88"

  touch "$AE_HOME/.datasets"
  popd # datasets
else
  echo "Datasets is prepared, skip"
fi

popd # AE_HOME
