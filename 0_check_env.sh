#!/usr/bin/env bash

source ./common.sh

function check_exec() {
  cmd=$1
  if ! [ -x "$(command -v $cmd)" ]; then
    echo "Error: $cmd is not available." >&2
    exit 1
  fi
}

check_exec "wget"
check_exec "unzip"
check_exec "md5sum"
check_exec "tar"
check_exec "cmake"
check_exec "conda"